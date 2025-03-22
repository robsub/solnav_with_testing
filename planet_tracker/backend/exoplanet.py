from flask import Flask, jsonify, request
from datetime import datetime
import ephem
import math

app = Flask(__name__)

# Sample exoplanet data (you would typically load this from a database)
exoplanets = {
    "Proxima Centauri b": {
        "star": "Proxima Centauri",
        "mass": 1.27,  # Earth masses
        "radius": 1.08,  # Earth radii
        "period": 11.2,  # days
        "semi_major_axis": 0.0485,  # AU
        "eccentricity": 0.11,
        "inclination": 0.0,  # degrees
    },
    "TRAPPIST-1e": {
        "star": "TRAPPIST-1",
        "mass": 0.77,
        "radius": 0.92,
        "period": 6.1,
        "semi_major_axis": 0.02817,
        "eccentricity": 0.005,
        "inclination": 89.736,
    },
    # Add more exoplanets as needed
}

def calculate_exoplanet_positions(date_str):
    date = ephem.Date(date_str)
    positions = {"exoplanets": {}}

    for name, data in exoplanets.items():
        # Calculate the mean anomaly
        days_since_epoch = date - ephem.Date('2000/1/1')
        mean_anomaly = (days_since_epoch % data['period']) / data['period'] * 360

        # Convert mean anomaly to true anomaly (simplified, assuming circular orbit)
        true_anomaly = mean_anomaly

        # Calculate position (simplified, assuming circular orbit and no inclination)
        x = data['semi_major_axis'] * math.cos(math.radians(true_anomaly))
        y = data['semi_major_axis'] * math.sin(math.radians(true_anomaly))

        # Convert to spherical coordinates (simplified)
        r = math.sqrt(x**2 + y**2)
        theta = math.degrees(math.atan2(y, x))

        positions['exoplanets'][name] = {
            "r": r,  # Distance from star in AU
            "theta": theta,  # Angle in degrees
            "star": data['star'],
            "mass": data['mass'],
            "radius": data['radius'],
        }

    return positions

@app.route('/exoplanet_positions', methods=['GET'])
def get_exoplanet_positions():
    date_str = request.args.get('date', datetime.now().strftime('%Y-%m-%d'))
    exoplanet_positions = calculate_exoplanet_positions(date_str)
    return jsonify(exoplanet_positions)

if __name__ == '__main__':
    app.run(debug=True)