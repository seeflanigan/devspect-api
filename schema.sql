CREATE TABLE pivotal_tracker_activities (
  id SERIAL PRIMARY KEY,
  author_name CHARACTER VARYING,
  description CHARACTER VARYING,
  occurred_at TIMESTAMP WITH TIME ZONE,
  activity_type CHARACTER VARYING,
  project_id INTEGER,
  story_id INTEGER
);

CREATE TABLE pivotal_tracker_story_statuses (
  id SERIAL PRIMARY KEY,
  description CHARACTER VARYING
);

CREATE TABLE pivotal_tracker_story_histories (
  id SERIAL PRIMARY KEY,
  start_date TIMESTAMP WITH TIME ZONE,
  end_date TIMESTAMP WITH TIME ZONE,
  status_id INTEGER,
  story_id INTEGER
);

CREATE TABLE pivotal_tracker_stories (
  id SERIAL PRIMARY KEY,
  name CHARACTER VARYING,
  accepted_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE,
  deadline INTEGER,
  description CHARACTER VARYING,
  estimate INTEGER,
  integration_id INTEGER,
  jira_id INTEGER,
  jira_url CHARACTER VARYING,
  labels CHARACTER VARYING,
  other_id INTEGER,
  owned_by CHARACTER VARYING,
  project_id INTEGER,
  requested_by CHARACTER VARYING,
  story_type CHARACTER VARYING,
  url CHARACTER VARYING
);

CREATE TABLE pivotal_tracker_projects (
  id SERIAL PRIMARY KEY,
  owner CHARACTER VARYING,
  current_iteration_number INTEGER,
  current_velocity INTEGER,
  first_iteration_start_time TIMESTAMP WITH TIME ZONE,
  initial_velocity INTEGER,
  iteration_length INTEGER,
  labels CHARACTER VARYING,
  last_activity_at TIMESTAMP WITH TIME ZONE,
  name CHARACTER VARYING,
  point_scale INTEGER[],
  velocity_scheme CHARACTER VARYING,
  week_start_day CHARACTER VARYING
);

CREATE VIEW cfd_summary AS
  SELECT date_trunc('day', h.start_date) AS status_date,
         a.description, sum(1)           AS count
  FROM pivotal_tracker_stories s INNER JOIN
       pivotal_tracker_story_histories h ON h.story_id = s.id INNER JOIN
       pivotal_tracker_story_statuses a ON a.id = h.status_id
  GROUP BY status_date,
           a.description
