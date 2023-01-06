rollback;
begin;
	delete from Users;
	insert into Users values('a','a','a');
	insert into Users values('b','a','a');
	insert into Users values('c','a','a');
	insert into Users values('d','a','a');
	insert into Users values('e','a','a');	
	insert into Poll values(
		'PollName',
		'a',
		array [timestamp'1999-01-08 04:05:06', timestamp'1999-01-08 02:05:06'],
		'1999-01-09 04:05:06',
		'PollDescription'
	);
	insert into Location values('LocationA','PollName','a','LocationADesc','urlA',0,10);
	insert into Location values('LocationB','PollName','a','LocationBDesc','urlB',0,20);
	insert into Location values('LocationC','PollName','a','LocationCDesc','urlC',0,30);
	insert into PollVote values('PollName','a','a','LocationA','1999-01-08 04:05:06');
	insert into PollVote values('PollName','a','b','LocationA','1999-01-08 04:05:06');
	insert into PollVote values('PollName','a','c','LocationA','1999-01-08 04:05:06');
	insert into PollVote values('PollName','a','a','LocationB','1999-01-08 04:05:06');
	insert into PollVote values('PollName','a','b','LocationB','1999-01-08 04:05:06');
	insert into PollVote values('PollName','a','a','LocationC','1999-01-08 02:05:06');
	insert into PollVote values('PollName','a','b','LocationB','1999-01-08 02:05:06');
end;

select * from Users;

select LocationName, Date, count(*)
from PollVote
where PollName = 'PollName' and OrganizerUserName = 'a'
group by LocationName, Date
order by count desc
limit 1;

select * from Poll;
delete from Poll where 1 = 1;
select * from Event;




