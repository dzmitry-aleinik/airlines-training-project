-- types --
create type order_status as enum (
  'Cancelled', 
  'Confirmed', 
  'Pending'
);

create type order_with_total as (
	order_id integer,
	order_number integer,
	status order_status,
	expires_at timestamp,
  total integer
);

create type order_with_date_from as (
	order_id integer,
	order_number integer,
	status order_status,
	expires_at timestamp,
  date_from timestamp
);

create type place as (
	place_id integer,
	place_number varchar(255),
	type_name varchar(255),
	price integer
);

create type flight_brief as (
	flight_id integer,
	city_from varchar(255),
	city_to varchar(255),
	date_from timestamp,
	date_to timestamp,
	plane_id integer,
	plane_type varchar(255),
	free_kg integer,
	max_kg integer,
	price_for_kg integer
);

create type flight_expanded as (
	flight_id integer,
	city_from varchar(255),
	city_to varchar(255),
	date_from timestamp,
	date_to timestamp,
	plane_id integer,
	plane_type varchar(255),
	luggage_kg integer,
	max_kg integer,
	free_kg integer,
	price_for_kg integer
);

create type user_main_info as (
	user_id integer,
	email varchar(255),
	nickname varchar(255)
);

create type password_data as (
  password_hash text, 
  password_salt text
);

-- tables --
create table users (
	user_id serial primary key,
	email varchar(255) not null,
	password_hash text not null,
	password_salt text not null,
	nickname varchar(255),
	avatar bytea not null
);

create table planes (
  plane_id serial primary key,
  type varchar(255) not null
);

create table place_types (
	type_id serial primary key,
	plane_id integer references planes not null,
	type_name varchar(255) not null,
	price integer not null
);

create table places (
	place_id serial primary key,
	type_id integer references place_types not null,
	plane_id integer references planes not null,
	place_number varchar(255) not null,
	availability boolean not null
);

create table orders (
	order_id serial primary key,
	user_id integer references users not null,
  order_number integer not null,
	status order_status not null,
	total integer not null,
	expires_at timestamp
);

create table flights (
	flight_id serial primary key,
	city_from varchar(255) not null,
	city_to varchar(255) not null,
	date_from timestamp not null,
	date_to date timestamp null,
  plane_id integer references planes not null
);

create table ordered_flights (
  ordered_flight_id serial primary key,
  flight_id integer references flights not null,
  order_id integer references orders not null,
  luggage_kg integer
);

create table ordered_places (
	ordered_flight_id integer references ordered_flights not null,
	place_id integer references places not null
);

create table luggage_schemas (
	luggage_schema_id serial primary key,
	plane_id integer references planes not null,
	max_kg integer not null,
	free_kg integer not null,
	price_for_kg integer not null
)

-- functions --
create function get_orders_by_user_id(id integer)
	returns table (ord order_with_date_from) as $$
begin
  return query select o.order_id, o.order_number, o.status, o.expires_at, f.date_from 
  from orders o natural join ordered_flights natural join flights f 
  where o.user_id=id;
end;
$$ language plpgsql;

create function get_order_by_id(id integer)
	returns order_with_total as $$
declare ret order_with_total;
begin
	select order_id, order_number, status, expires_at, total 
  into ret from orders where id=order_id;
  return ret;
end;
$$ language plpgsql;

create function get_ordered_flights(ord_id integer)
	returns table (flgt flight_expanded) as $$
begin
  return query 
    select f.*, p.type as plane_type, of.luggage_kg, 
    lsc.max_kg, lsc.free_kg, lsc.price_for_kg
  from ordered_flights of natural join flights f 
    natural join planes p natural join luggage_schemas lsc 
  where of.order_id=ord_id;
end;
$$ language plpgsql;

create function get_ordered_places(fl_id integer)
	returns table (plc place) as $$
begin
  return query select p.place_id, p.place_number, pt.type_name, pt.price 
  from ordered_places natural join places p natural join place_types pt 
  where flight_id=fl_id;
end;
$$ language plpgsql;

create function insert_user(user_email varchar(255), user_hash text, user_salt text, user_avatar bytea)
	returns void as $$
declare temp integer;
begin
  insert into users(email, password_hash, password_salt, avatar) 
    values(user_email, user_hash, user_salt, user_avatar);
  update users set nickname='User#' || user_id where email=user_email;
  return;
end;
$$ language plpgsql;

create function get_user_by_email(user_email character varying)
  returns user_main_info as $$
declare ret user_main_info;
begin
  select user_id, email, nickname, avatar into ret from users where user_email=email;
  return ret;
end;
$$ language plpgsql;

create function get_password_data(id integer)
  returns password_data as $$
declare ret password_data;
begin
  select password_hash, password_salt into ret from users where user_id=id;
  return ret;
end;
$$ language plpgsql;

create function get_all_cities()
	returns table(city varchar(255)) as $$
begin
	return query select distinct city_from as city from 
		(select city_from from flights
		union all
		select city_to from flights) as t1;
end;
$$ language plpgsql;

create function get_available_places(pl_id integer, fl_id integer)
	returns table (place_id integer) as $$
begin
	return query select places.place_id from places 
	where plane_id=pl_id and places.place_id not in 
	(select ordered_places.place_id from ordered_places where flight_id=fl_id);
end;
$$ language plpgsql;

create function get_flights_by_filters(c_from varchar(255), c_to varchar(255), d_from timestamp, d_to timestamp, seats integer)
	returns table (fs flight_brief) as $$
begin
	return query select f.*, type as plane_type, free_kg, max_kg, price_for_kg 
	from flights f natural join planes natural join luggage_schemas
	where f.city_from=c_from and f.city_to=c_to and f.date_from>=d_from and f.date_to<=d_to and
	seats<=(select count(*) from get_available_places(f.plane_id, f.flight_id));
end;
$$ language plpgsql;