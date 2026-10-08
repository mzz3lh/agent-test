# CI-only scripts

`agents/tools/ci.py database` (the project CI) runs every `*.sql` here, in name order, on its throwaway
database after installing tSQLt and before applying the migrations. Use it only for objects that exist in
the real databases but are not this project's to deploy, such as the source tables another system's extract
lands in, so the migrations and suites can run from nothing. Never put this project's own objects or any
real data here.
