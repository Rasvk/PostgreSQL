/*
* Author: Rasmus Vedholm Krog
* Version: 1.0
* Date: 24.09.15
* Answer to innlevering 6 in INF1300 fall 2015
*/

create schema bedrift; -- create new schema bedrift

set search_path to "$user$",bedrift; -- changes path to the users new schema

create table Kunde (
       kundenr int primary key,
       kundenavn varchar(50),
       postadresse varchar(100),
       fakturaadresse varchar(100)
);

create table Offentlig_Etat (
       kundenr int primary key references Kunde,
       departement varchar(100)
);

create table Firma (
       kundenr int primary key references Kunde,
       orgnr int unique
);

create table Telefonnummer (
       tlfnr char(8) primary key,
       kundenr int references Kunde
);



create table Gruppe (
       gruppenavn varchar(100) primary key,
       lonn numeric
);

create table Ansatt (
       ansattnr int primary key,
       gruppenavn varchar(100) references Gruppe
);


create table Prosjekt (
        prosjektnr int primary key,
       	leder int references Ansatt,
	navn varchar(100),
	kundenr int references Kunde
);

create table AnsattDeltarIProsjekt (
       ansattnr int references Ansatt,
       prosjektnr int references Prosjekt,
       primary key(ansattnr,prosjektnr)
);
/*
alter table prosjekt foreign key (leder,prosjektnr) references AnsattDeltarIProsjekt;

insert into prosjekt(prosjektnr, navn, kundenr) values (....);

insert into AnsattDeltarIProsjekt values (.....);

update prosjekt set leder =.... where prosjektnr =(...);
*/
\d 

select kundenr, kundenavn, postadresse from kunde;

select * from telefonnummer order by kundenr desc;

select distinct leder from prosjekt;

select ansattnr from AnsattDeltarIProsjekt adp, prosjekt p where p.navn='Ruter app' and adp.prosjektnr = p.prosjektnr;

select ansattnr, lonn from ansatt a, gruppe g where a.gruppenavn = g.gruppenavn;

select orgnr, kundenavn from firma f, kunde k, offentlig_etat oe where f.kundenr = k.kundenr and f.kundenr = oe.kundenr;
