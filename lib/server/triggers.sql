/*ON POLL DELETE CREATE EVENT----------------------------------------------------------------------------------------------------*/
create or replace function poll_to_event()
returns trigger as
$$
declare
	most_voted record; most_voted_location record;
begin
	select LocationName, Date, count(*) into most_voted
	from PollVote
	where PollName = old.PollName and OrganizerUserName = old.OrganizerUserName
	group by LocationName, Date
	order by count desc
	limit 1;
	
	select * into most_voted_location
    from Location
    where LocationName = most_voted.LocationName and
	PollName = old.PollName and OrganizerUserName = old.OrganizerUserName;
	
	insert into Event values(
		old.PollName,
		old.OrganizerUserName,
		old.PollDescription,
		most_voted_location.LocationName,
		most_voted_location.LocationDescription,
		most_voted_location.LocationSite,
		most_voted_location.Lat,
		most_voted_location.Lon,
		most_voted.Date
	);
	return old;
end;
$$ language plpgsql;

drop trigger if exists poll_to_event on Poll;
create trigger poll_to_event before delete on Poll for each row execute procedure poll_to_event();

/*MUTUAL FRIENDSHIP----------------------------------------------------------------------------------------------------*/
create or replace function mutual_friendship()
returns trigger as
$$
begin
	if(not exists(
		select * 
		from Friend 
		where (UserName1 = new.Username1 and UserName2 = new.UserName2) or
			(UserName1 = new.Username2 and UserName2 = new.UserName1)
		)) then
		return new; --ok va bene, inseriscimi la nuova tupla
	else
		return null; --essendo before, ritorna null come nuova tupla da inserire
	end if;
end;
$$ language plpgsql;

drop trigger if exists mutual_friendship on Friend;
create trigger mutual_friendship before insert on Friend for each row execute procedure mutual_friendship();
