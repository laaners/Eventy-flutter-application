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
	Password varchar(200) not null,
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
	LocationSite text,
	Lat numeric,
	Lon numeric,
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
	LocationSite text,
	Lat numeric,
	Lon numeric,
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
