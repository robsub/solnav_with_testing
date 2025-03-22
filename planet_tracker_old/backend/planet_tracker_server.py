from flask import Flask, jsonify, request
from planet_calculations import calculate_planet_positions
from datetime import datetime

app = Flask(__name__)

@app.route('/planet_positions', methods=['GET'])
def get_planet_positions():
    date_str = request.args.get('date', datetime.now().strftime('%Y-%m-%d'))
    latitude = float(request.args.get('latitude', 40.7128))
    longitude = float(request.args.get('longitude', -74.0060))
    
    planet_positions = calculate_planet_positions(date_str, latitude, longitude)
    return jsonify(planet_positions)

if __name__ == '__main__':
    app.run(debug=True)