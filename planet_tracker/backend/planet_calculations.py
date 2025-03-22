import numpy as np
import pandas as pd
from skyfield.api import load, wgs84
from datetime import datetime, timedelta
import pytz
import json

# Load ephemeris data
eph = load('de421.bsp')

def calculate_planet_positions(date_str, latitude, longitude):
    # Convert string date to datetime object
    date = datetime.strptime(date_str, '%Y-%m-%d')
    
    # Set up location and time zone
    location = wgs84.latlon(latitude, longitude)
    timezone = pytz.timezone('UTC')  # Use UTC for simplicity, adjust as needed
    
    # Set up time range for calculations (full 24 hours, hourly intervals)
    start_time = datetime(date.year, date.month, date.day, 0, 0, 0, tzinfo=timezone)
    end_time = datetime(date.year, date.month, date.day, 23, 59, 59, tzinfo=timezone)
    time_range = pd.date_range(start=start_time, end=end_time, freq='1H')  # '1H' = hourly
    
    # Set up planets
    earth = eph['earth']
    planet_names = ['mars', 'jupiter barycenter', 'saturn barycenter', 'venus', 'mercury']
    planets = [eph[name] for name in planet_names]
    
    # Prepare results dictionary
    results = {'date': date_str, 'latitude': latitude, 'longitude': longitude, 'planets': {}}
    
    # Calculate planet positions
    for planet, name in zip(planets, planet_names):
        planet_positions = []
        for t in time_range:
            t_sf = load.timescale().from_datetime(t)
            topocentric = (earth + location).at(t_sf).observe(planet)
            alt, az, _ = topocentric.apparent().altaz()  # Get altitude (vertical) and azimuth (horizontal)
            
            # Append positions (in degrees)
            planet_positions.append({
                'time': t.strftime('%Y-%m-%d %H:%M:%S'),
                'altitude': alt.degrees,  # Vertical position
                'azimuth': az.degrees,    # Horizontal position
            })
        
        results['planets'][name] = planet_positions
    
    return results