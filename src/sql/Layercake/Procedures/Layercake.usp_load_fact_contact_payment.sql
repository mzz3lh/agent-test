/*====================================================================
    Layercake.usp_load_fact_contact_payment
    Contact payment dataset - full-rebuild load (DES-001, ADR-001)
====================================================================*/

/*====================================================================
    Layercake.vw_fact_contact_payment_source -> Layercake.fact_contact_payment

    Replaces the table's whole content with the view's current output
    in one transaction, so readers see either the previous or the new
    dataset, FO corrections and removals are reflected, and contacts'
    current countries are restated on every run (AC-006-05). All rules
    live in the view; this procedure only persists its output.

    Logging follows the Layercake convention (usp_etl_log_start /
    usp_etl_log_end under the orchestrator's @run_id). Errors also go
    to audit.ErrorLog (base standard); its LoadId refers to
    audit.LoadLog, which Layercake loads do not use, so it stays NULL.

    A source holding the same legal entity and RECID twice fails on
    the primary key and leaves the previous content in place, rather
    than dropping a payment (RULE-004).

    DELETE rather than TRUNCATE: it gives the deleted row count and
    needs no ALTER permission on the table.

    Parameters:
      @run_id - orchestrator run id (generated if standalone)
====================================================================*/
CREATE OR ALTER PROCEDURE Layercake.usp_load_fact_contact_payment
    @run_id uniqueidentifier = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @run_id IS NULL SET @run_id = NEWID();

    DECLARE
        @log_id bigint,
        @ins int,
        @del int,
        @loaded_at datetime2(3) = SYSUTCDATETIME(),
        @err nvarchar(4000);

    BEGIN TRY
        -- before the transaction, so the start entry survives a rollback
        EXEC Layercake.usp_etl_log_start @run_id, 'gold', 'fact_contact_payment', @log_id OUTPUT;

        BEGIN TRANSACTION;

        DELETE FROM Layercake.fact_contact_payment;
        SET @del = @@ROWCOUNT;

        INSERT INTO Layercake.fact_contact_payment (
            legal_entity,
            fo_transaction_recid,
            account_number,
            contact_number,
            is_corporate,
            payment_date,
            payment_year,
            payment_month,
            amount_paid_currency,
            currency_code,
            amount_paid_gbp,
            payment_method_code,
            payment_method,
            country_name,
            region_name,
            market_reporting_region,
            run_id,
            created_at,
            updated_at
        )
        SELECT
            src.legal_entity,
            src.fo_transaction_recid,
            src.account_number,
            src.contact_number,
            src.is_corporate,
            src.payment_date,
            src.payment_year,
            src.payment_month,
            src.amount_paid_currency,
            src.currency_code,
            src.amount_paid_gbp,
            src.payment_method_code,
            src.payment_method,
            src.country_name,
            src.region_name,
            src.market_reporting_region,
            @run_id,
            @loaded_at,
            @loaded_at
        FROM Layercake.vw_fact_contact_payment_source AS src;
        SET @ins = @@ROWCOUNT;

        COMMIT TRANSACTION;

        -- a full rebuild updates no rows
        EXEC Layercake.usp_etl_log_end @log_id, 'Success', @ins, 0, @del;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;

        EXEC audit.usp_LogError;

        SET @err = CONCAT(ERROR_MESSAGE(), N' (error ', ERROR_NUMBER(), N', line ', ERROR_LINE(), N')');
        -- the work was rolled back, so nothing was inserted or deleted
        IF @log_id IS NOT NULL
            EXEC Layercake.usp_etl_log_end @log_id, 'Failed', 0, 0, 0, @err;

        THROW;
    END CATCH;
END;
