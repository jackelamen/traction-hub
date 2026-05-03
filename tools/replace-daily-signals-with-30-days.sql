-- Replace the oversized Samsung Health daily signal JSON with the trimmed 30-day payload.
-- Run this in the Supabase SQL editor if the in-place prune query times out.

update traction_data
set
  value = '{
  "2026-04-27": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.405Z",
    "hrvRmssd": 67.4,
    "respiratoryRate": 13,
    "skinTemperatureC": 33.4,
    "spo2": 94,
    "spo2Min": 92,
    "steps": 10815,
    "sleepHours": 5.72,
    "exerciseMins": 24
  },
  "2026-04-18": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 100.6,
    "respiratoryRate": 13.1,
    "skinTemperatureC": 34.8,
    "spo2": 93.3,
    "spo2Min": 89,
    "steps": 9532,
    "exerciseMins": 51
  },
  "2026-04-20": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 60.6,
    "respiratoryRate": 13.1,
    "skinTemperatureC": 35.5,
    "spo2": 92.9,
    "spo2Min": 70,
    "steps": 12449,
    "exerciseMins": 55
  },
  "2026-04-26": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 54.9,
    "respiratoryRate": 13.1,
    "skinTemperatureC": 33.8,
    "spo2": 95.1,
    "spo2Min": 91,
    "steps": 13804,
    "exerciseMins": 44
  },
  "2026-04-04": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 65.6,
    "respiratoryRate": 13.5,
    "skinTemperatureC": 34.4,
    "spo2": 94.9,
    "spo2Min": 92,
    "steps": 8965,
    "sleepHours": 7.72,
    "exerciseMins": 25
  },
  "2026-04-08": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 61.4,
    "respiratoryRate": 13.1,
    "skinTemperatureC": 34,
    "spo2": 94.1,
    "spo2Min": 85,
    "steps": 11017,
    "exerciseMins": 42
  },
  "2026-04-10": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 42,
    "respiratoryRate": 12.8,
    "skinTemperatureC": 34.2,
    "spo2": 95.3,
    "spo2Min": 93,
    "steps": 10820,
    "exerciseMins": 64
  },
  "2026-04-06": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 46.2,
    "respiratoryRate": 13.4,
    "skinTemperatureC": 33.4,
    "spo2": 95.5,
    "spo2Min": 93,
    "steps": 4881,
    "exerciseMins": 12
  },
  "2026-04-07": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 55.2,
    "respiratoryRate": 13.1,
    "skinTemperatureC": 34.7,
    "spo2": 92.9,
    "spo2Min": 90,
    "steps": 8455,
    "exerciseMins": 53
  },
  "2026-04-14": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 85.9,
    "respiratoryRate": 12.7,
    "skinTemperatureC": 34.2,
    "spo2": 94.3,
    "spo2Min": 89,
    "steps": 9743,
    "exerciseMins": 38
  },
  "2026-04-22": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 62.3,
    "respiratoryRate": 13.1,
    "skinTemperatureC": 35,
    "spo2": 94.6,
    "spo2Min": 90,
    "steps": 10825,
    "sleepHours": 8.45,
    "exerciseMins": 23
  },
  "2026-04-23": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 41.6,
    "respiratoryRate": 13,
    "skinTemperatureC": 34.6,
    "spo2": 95.3,
    "spo2Min": 92,
    "steps": 8141,
    "sleepHours": 7.48,
    "exerciseMins": 49
  },
  "2026-04-12": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 73.2,
    "respiratoryRate": 12.6,
    "skinTemperatureC": 32.7,
    "spo2": 94.6,
    "spo2Min": 92,
    "steps": 6044
  },
  "2026-04-19": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 59.9,
    "respiratoryRate": 13.3,
    "skinTemperatureC": 33.6,
    "spo2": 93.8,
    "spo2Min": 80,
    "steps": 9178
  },
  "2026-04-30": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 62.9,
    "respiratoryRate": 12.2,
    "skinTemperatureC": 34.7,
    "spo2": 94.7,
    "spo2Min": 90,
    "steps": 7091
  },
  "2026-04-25": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 49.1,
    "respiratoryRate": 13.7,
    "skinTemperatureC": 35.3,
    "spo2": 94.9,
    "spo2Min": 94,
    "steps": 4151
  },
  "2026-04-28": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 70.9,
    "respiratoryRate": 13.1,
    "skinTemperatureC": 34,
    "spo2": 94.8,
    "spo2Min": 90,
    "steps": 10005,
    "exerciseMins": 39
  },
  "2026-04-09": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 50.5,
    "respiratoryRate": 12.5,
    "skinTemperatureC": 34.2,
    "spo2": 94.9,
    "spo2Min": 92,
    "steps": 4980
  },
  "2026-04-21": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 68.8,
    "respiratoryRate": 12.6,
    "skinTemperatureC": 34.4,
    "spo2": 94.4,
    "spo2Min": 89,
    "steps": 10236,
    "exerciseMins": 59
  },
  "2026-04-24": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 47.5,
    "respiratoryRate": 13.5,
    "skinTemperatureC": 34,
    "spo2": 95.2,
    "spo2Min": 92,
    "steps": 12511,
    "exerciseMins": 16
  },
  "2026-04-13": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 67.7,
    "respiratoryRate": 12.7,
    "skinTemperatureC": 33.6,
    "spo2": 94.2,
    "spo2Min": 87,
    "steps": 8083,
    "exerciseMins": 10
  },
  "2026-04-16": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 44.4,
    "respiratoryRate": 12.4,
    "skinTemperatureC": 34.6,
    "spo2": 94.9,
    "spo2Min": 94,
    "steps": 6456,
    "exerciseMins": 24
  },
  "2026-04-17": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 59.6,
    "respiratoryRate": 12.9,
    "skinTemperatureC": 34,
    "spo2": 94.1,
    "spo2Min": 82,
    "steps": 10204,
    "sleepHours": 5.95,
    "exerciseMins": 13
  },
  "2026-05-01": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 48,
    "respiratoryRate": 13.3,
    "skinTemperatureC": 33.9,
    "spo2": 94.7,
    "spo2Min": 91,
    "steps": 8100
  },
  "2026-04-05": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 59.1,
    "respiratoryRate": 12.7,
    "skinTemperatureC": 34.8,
    "spo2": 94.1,
    "spo2Min": 82,
    "steps": 2998
  },
  "2026-04-15": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 54.8,
    "respiratoryRate": 13.4,
    "skinTemperatureC": 33.5,
    "spo2": 93.5,
    "spo2Min": 90,
    "steps": 11345,
    "exerciseMins": 28
  },
  "2026-04-29": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:36.406Z",
    "hrvRmssd": 61.3,
    "respiratoryRate": 12.8,
    "skinTemperatureC": 34.5,
    "spo2": 94.8,
    "spo2Min": 92,
    "steps": 13481,
    "exerciseMins": 57
  },
  "2026-04-11": {
    "source": "Samsung Health",
    "updatedAt": "2026-05-03T03:31:40.114Z",
    "steps": 9811
  }
}'::jsonb,
  updated_at = now()
where
  user_id = 'jack_traction_hub_v1'
  and key = 'edgex_daily_signals_v1';

-- Check the result after running.
select
  (select count(*) from jsonb_object_keys(value)) as kept_days,
  pg_size_pretty(pg_column_size(value)::bigint) as json_size
from traction_data
where
  user_id = 'jack_traction_hub_v1'
  and key = 'edgex_daily_signals_v1';
