drop table if exists PollVote;
drop table if exists Location;
drop table if exists PollInvite;
drop table if exists EventInvite;
drop table if exists GroupAdmin;
drop table if exists GroupMember;
drop table if exists Friend;

drop table if exists Poll;
drop table if exists Event;
drop table if exists Groups;
drop table if exists Users;

create table Users(
	UserName varchar(40) primary key,
	Name varchar(40) not null,
	Password varchar(40) not null,
	Picture bytea
);

create table Poll(
	PollName varchar(40),
	OrganizerUserName varchar(40),
	Dates timestamp[],
	Deadline timestamp not null,
	PollDescription varchar(200),
	constraint Poll_PK primary key (PollName, OrganizerUserName),
	constraint Poll_FK foreign key (OrganizerUserName) references Users(UserName) on delete cascade
);

create table Location(
	LocationName varchar(40),
	PollName varchar(40),
	OrganizerUserName varchar(40),
	LocationDescription varchar(200),
	LocationSite text not null,
	constraint Location_PK primary key (LocationName, PollName, OrganizerUserName),
	constraint Location_FK foreign key (PollName, OrganizerUserName) references Poll(PollName, OrganizerUserName) on delete cascade
);

create table PollVote(
	PollName varchar(40),
	OrganizerUserName varchar(40),
	VoterUserName varchar(40),
	LocationName text,
	Date timestamp,
	constraint PollVote_PK primary key (PollName, OrganizerUserName, VoterUserName, LocationName, Date),
	constraint PollVote_Poll_FK foreign key (PollName, OrganizerUserName) references Poll(PollName, OrganizerUserName) on delete cascade,
	constraint PollVote_Voter_FK foreign key (VoterUserName) references Users(UserName) on delete cascade,
	constraint PollVote_Location_FK foreign key (LocationName, PollName, OrganizerUserName) references Location(LocationName, PollName, OrganizerUserName) on delete cascade
);

create table PollInvite(
	PollName varchar(40),
	OrganizerUserName varchar(40),
	InviteeUserName varchar(40),
	constraint PollInvite_PK primary key (PollName, OrganizerUserName, InviteeUserName),
	constraint PollInvite_Poll_FK foreign key (PollName, OrganizerUserName) references Poll(PollName, OrganizerUserName) on delete cascade,
	constraint PollInvite_Invitee_FK foreign key (InviteeUserName) references Users(UserName) on delete cascade
);

create table Event(
	EventName varchar(40),
	OrganizerUserName varchar(40),
	EventDescription varchar(200),
	LocationName varchar(40),
	LocationDescription varchar(200),
	LocationSite text not null,
	Date timestamp,
	constraint Event_PK primary key (EventName, OrganizerUserName),
	constraint Event_FK foreign key (OrganizerUserName) references Users(UserName) on delete cascade
);

create table EventInvite(
	EventName varchar(40),
	OrganizerUserName varchar(40),
	InviteeUserName varchar(40),
	Presence boolean,
	constraint EventInvite_PK primary key (EventName, OrganizerUserName, InviteeUserName),
	constraint EventInvite_Poll_FK foreign key (EventName, OrganizerUserName) references Event(EventName, OrganizerUserName) on delete cascade,
	constraint EventInvite_Invitee_FK foreign key (InviteeUserName) references Users(UserName) on delete cascade
);

create table Groups(
	GroupId uuid primary key,
	GroupName varchar(40) not null,
	GroupDescription varchar(200),
	Picture bytea
);

create table GroupAdmin(
	GroupId uuid primary key,
	AdminUserName varchar(40),
	constraint GroupAdmin_Group_FK foreign key (GroupId) references Groups(GroupId) on delete cascade,
	constraint GroupAdmin_Admin_FK foreign key (AdminUserName) references Users(UserName) on delete cascade
);

create table GroupMember(
	GroupId uuid primary key,
	MemberUserName varchar(40),
	constraint GroupMember_Group_FK foreign key (GroupId) references Groups(GroupId) on delete cascade,
	constraint GroupMember_Member_FK foreign key (MemberUserName) references Users(UserName) on delete cascade
);

create table Friend(
	UserName1 varchar(40),
	UserName2 varchar(40),
	constraint Friend_PK primary key (UserName1, UserName2),
	constraint Friend_FK1 foreign key (UserName1) references Users(UserName) on delete cascade,
	constraint Friend_FK2 foreign key (UserName2) references Users(UserName) on delete cascade
);

/*
Users(UserName, Name, Password, Picture*)
Poll(PollName, OrganizerUserName, Locations[], Dates[], Deadline)
PollVote(PollName, OrganizerUserName, VoterUserName, Location, Date)
PollInvite(PollName, OrganizerUserName, InviteeUserName)

Event(EventName, OrganizerUserName, Location, Date)
EventInvite(EventName, OrganizerUserName, InviteeUserName, Presence)

Groups(GroupId, GroupName, Picture*)
GroupAdmin(GroupId, AdminUserName)
GroupMember(GroupId, MemberUserName)

Friend(UserName1, UserName2)


drop table if exists giocatore cascade;
drop table if exists squadra cascade;

create table giocatore (
	codice varchar(20) constraint pk_codice primary key,
	anno int,
	citta varchar(30) constraint vincolo_citta_nascita not null,
	sq varchar(20) constraint vincolo_squadra not null,
	constraint vincolo_anno check (anno > 1920 and anno < 2020)
);

create table squadra (
	nome varchar(20) constraint pk_squadra primary key,
	citta varchar(30),
	capitano varchar(20) constraint vincolo_capitano not null constraint fk_sq_cap references giocatore(codice) on update cascade deferrable
);

alter table giocatore 
add constraint fk_gio_sq foreign key (sq) references squadra(nome) on delete cascade deferrable;

--alter table squadra
--add constraint fk_sq_cap foreign key (capitano) references giocatore(codice) on update cascade deferrable;

/*1. Qualunque siano x e y, se x è il capitano della squadra y, allora x milita nella squadra y.*/-------------------------------------------------------

/*Già verificato da tutte le altre condizioni!!!
Come si dimostra? 
DIMOSTRAZIONE INVARIANTE, condizione sempre verificata nel codice
a) Appena inserito nuova squadra S
	1) è soddisfatto, ispezionando un codice
b) Analizzo tutte le operazioni che 
	potenzialmente violano 1)*/

/*2. Deve essere proibito inserire una nuova tupla nella tabella squadra se non attraverso--------------------------------------------------------
l’inserimento di una tupla di giocatore, che rappresenta il suo capitano. In altre parole, per
inserire una squadra l’unico modo che deve essere reso disponibile è inserire un nuovo
giocatore che rappresenta il suo capitano.*/

--Posso impedire inserimento se succede cosa opposta, se x capitano non sia giocatore
create or replace function insert_squadra()
returns trigger as
$$
begin
	--Inserisco squadra con il capitano che sta già nella squadra giusta
	if(new.capitano in (select codice from giocatore where sq = new.nome)) then
		return new; --ok va bene, inseriscimi la nuova tuplae
	else
		return null; --essendo before, ritorna null come nuova tupla da inserire
	end if;
end;
$$ language plpgsql;

create trigger insert_squadra before insert on squadra for each row execute procedure insert_squadra();

/*Già soddisfatto dal punto 1 e dai vincoli di chiave primaria del giocatore e i vincoli
di foreign key*/

/*3. Quando si cancella una squadra si devono cancellare tutti i giocatori che militano nella-------------------------------------------------------
squadra.*/

/*Soddisfatto da delete cascade del vincolo fk_gio_sq*/
--delete from squadra where nome = 'S2';

/*4. Deve essere proibito cambiare il nome ad una squadra.*/--------------------------------------------------------------------------------------

--Associo un trigger su update squadra che non cambia il nome
--basta confrontare old.nome con new.nome, se diversi return null
--update squadra set nome = 'S3' where nome = 'S1'

/*5. Deve essere proibito cancellare un giocatore o cambiare squadra ad un giocatore se esso è-------------------------------------------------
il capitano di una squadra.*/

/*Cancellazione soddisfatto dal vincolo fk_sq_cap*/
--delete from giocatore where codice = 'G1'

/*Update*/
create or replace function capNoUpdate(codice varchar, sq varchar)
returns varchar as
$$
begin
	if (codice in (select capitano from squadra)) then
		return 'false';
	else
		return 'true';
	end if;
end;
$$ language plpgsql;

alter table giocatore
add constraint cap_no_updatesq check(capNoUpdate(codice,sq) = 'true');

--oppure creavo trigger BEFORE con RETURN NULL

--update giocatore set sq = 'S2' where codice = 'G1'
--delete from giocatore where codice = 'G1'

/*6. Quando si cambia il codice di un capitano, il codice deve essere cambiato nella tupla della-----------------------------------------------
corrispondente squadra.*/

/*Soddisfatto da update cascade sul vincolo fk_sq_cap*/
--update giocatore set codice = 'G4' where codice = 'G1'

begin;
	set constraints fk_gio_sq deferred;
	set constraints fk_sq_cap deferred;
	insert into giocatore values('G1',2000,'Roma','S1');
	insert into squadra values('S1','Roma','G1');
	
	insert into giocatore values('G2',1999,'Napoli','S2');
	insert into squadra values('S2','Napoli','G2');
	
	insert into giocatore values('G3',1998,'Milano','S3');
	insert into squadra values ('S3','Milano','G3');
	
	insert into giocatore values('G4',1998,'Genova','S4');
	insert into squadra values ('S4','Genova','G4');
	
	insert into giocatore values('G15',2000,'Brindisi','S5');
	insert into squadra values ('S5','Bologna','G15');
	
	insert into giocatore values('G5',1997,'Roma','S1');
	insert into giocatore values('G6',2001,'Milano','S2');
	insert into giocatore values('G7',2001,'Milano','S3');
	insert into giocatore values('G8',1997,'Napoli','S2');
	insert into giocatore values('G9',2000,'Torino','S1');
	insert into giocatore values('G10',2002,'Palermo','S3');
	insert into giocatore values('G11',2001,'Genova','S4');
	insert into giocatore values('G12',1999,'Bologna','S5');
	insert into giocatore values('G13',2000,'Firenze','S4');
	insert into giocatore values('G14',1999,'Bari','S5');
	
	insert into giocatore values('G16',2000,'Roma','S6');
	insert into squadra values('S6','Roma','G16');
	insert into giocatore values('G17',2002,'Torino','S6');
end;
/*	
begin;
	set constraints fk_gio_sq deferred;
	set constraints fk_sq_cap deferred;
	insert into giocatore values('G15',null,'Bari','S5');
	insert into squadra values('S5',null,'G15');
end;*/

select * from squadra;
select * from giocatore;



*/

