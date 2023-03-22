begin;

create role usr1_new_role LOGIN;

grant SELECT on "Company" to usr1_new_role;
grant SELECT on "Date" to usr1_new_role;
grant INSERT on "Fact" to usr1_new_role;
grant SELECT on "Fact" to usr1_new_role;
grant UPDATE on "Fact" to usr1_new_role;
grant SELECT on "Supply" to usr1_new_role;
grant SELECT on "view1" to usr1_new_role;
grant UPDATE on "view1" to usr1_new_role;

revoke role1 from usr1;
revoke role2 from usr1;
revoke role3 from usr1;

grant usr1_new_role to usr1;

commit;
