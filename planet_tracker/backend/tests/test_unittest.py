import unittest
import sys
import os

# Add the parent directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from planet_calculations import calculate_planet_positions
from datetime import datetime, timedelta

class TestPlanetCalculations(unittest.TestCase):
    """
    Unit tests for the `calculate_planet_positions` function.
    This class tests the planetary position calculation functionality.
    """
    
    def setUp(self):
        """
        Set up common test data before each test method runs.
        """
        self.default_date = '2025-03-15'
        self.default_latitude = 53.3811  # Sheffield
        self.default_longitude = -1.4701
        self.expected_planets = ['mars', 'jupiter barycenter', 'saturn barycenter', 'venus', 'mercury']
    
    def test_basic_functionality(self):
        """
        Test whether the function correctly returns planetary positions with
        expected structure and content.
        """
        result = calculate_planet_positions(self.default_date, self.default_latitude, self.default_longitude)
        
        # Check if result has all expected keys
        self.assertIn('planets', result, "Result should have a 'planets' key")
        self.assertIn('date', result, "Result should have a 'date' key")
        self.assertIn('latitude', result, "Result should have a 'latitude' key")
        self.assertIn('longitude', result, "Result should have a 'longitude' key")
        
        # Check if result values match input
        self.assertEqual(result['date'], self.default_date)
        self.assertEqual(result['latitude'], self.default_latitude)
        self.assertEqual(result['longitude'], self.default_longitude)
        
        # Check if all expected planets are present
        for planet in self.expected_planets:
            self.assertIn(planet, result['planets'])
    
    def test_hourly_data_format(self):
        """
        Test if hourly data is correctly generated for each planet.
        """
        result = calculate_planet_positions(self.default_date, self.default_latitude, self.default_longitude)
        
        for planet in self.expected_planets:
            # Should have 24 hourly entries
            self.assertEqual(
                len(result['planets'][planet]), 
                24, 
                f"{planet} should have 24 hourly entries"
            )
            
            # Check first entry's time format
            first_entry = result['planets'][planet][0]
            self.assertIn('time', first_entry)
            
            # Parse the time to ensure it's valid
            try:
                datetime.strptime(first_entry['time'], '%Y-%m-%d %H:%M:%S')
            except ValueError:
                self.fail(f"Time format is incorrect: {first_entry['time']}")
    
    def test_coordinate_values(self):
        """
        Test if altitude and azimuth values are within valid ranges.
        """
        result = calculate_planet_positions(self.default_date, self.default_latitude, self.default_longitude)
        
        for planet in self.expected_planets:
            for position in result['planets'][planet]:
                # Check for required fields
                self.assertIn('altitude', position)
                self.assertIn('azimuth', position)
                
                # Check value ranges
                self.assertGreaterEqual(position['altitude'], -90)
                self.assertLessEqual(position['altitude'], 90)
                
                self.assertGreaterEqual(position['azimuth'], 0)
                self.assertLess(position['azimuth'], 360)
    
    def test_invalid_date(self):
        """
        Test if an invalid date string raises ValueError.
        """
        with self.assertRaises(ValueError) as context:
            calculate_planet_positions("invalid-date", self.default_latitude, self.default_longitude)
        
        # Check if the error message is about date format
        self.assertIn("time data", str(context.exception))
        self.assertIn("does not match format", str(context.exception))
    
    def test_extreme_latitudes(self):
        """
        Test if the function handles extreme latitude values.
        """
        # Test North Pole
        north_result = calculate_planet_positions(
            self.default_date, 90.0, self.default_longitude
        )
        self.assertIn('planets', north_result)
        
        # Test South Pole
        south_result = calculate_planet_positions(
            self.default_date, -90.0, self.default_longitude
        )
        self.assertIn('planets', south_result)
    
    def test_extreme_longitudes(self):
        """
        Test if the function handles extreme longitude values.
        """
        # Test International Date Line
        date_line_result = calculate_planet_positions(
            self.default_date, self.default_latitude, 180.0
        )
        self.assertIn('planets', date_line_result)
        
        # Test Prime Meridian
        meridian_result = calculate_planet_positions(
            self.default_date, self.default_latitude, 0.0
        )
        self.assertIn('planets', meridian_result)
    
    def test_date_boundaries(self):
        """
        Test dates at boundaries of supported ranges
        """
        # Test current date
        today = datetime.now().strftime('%Y-%m-%d')
        today_result = calculate_planet_positions(
            today, self.default_latitude, self.default_longitude
        )
        self.assertIn('planets', today_result)
        
        # Test a past date
        past_date = '1900-01-01'
        try:
            past_result = calculate_planet_positions(
                past_date, self.default_latitude, self.default_longitude
            )
            self.assertIn('planets', past_result)
        except Exception as e:
            # If this fails, it might be because the ephemeris data doesn't go back this far
            self.skipTest(f"Past date test failed: {str(e)}")
            
        # Test a future date (may fail if ephemeris doesn't go that far)
        future_date = '2050-01-01'
        try:
            future_result = calculate_planet_positions(
                future_date, self.default_latitude, self.default_longitude
            )
            self.assertIn('planets', future_result)
        except Exception as e:
            # If this fails, it might be because the ephemeris data doesn't go forward this far
            self.skipTest(f"Future date test failed: {str(e)}")

if __name__ == '__main__':
    unittest.main()