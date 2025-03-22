import sys
import os

# Add the parent directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from planet_calculations import calculate_planet_positions
import math

def test_calculate_planet_positions():
    """
    Manually checks if calculate_planet_positions returns valid data using assert.
    This method does not use any testing framework.
    """
    date_str = '2025-03-15'
    latitude, longitude = 53.3811, -1.4701
    
    result = calculate_planet_positions(date_str, latitude, longitude)

    # Check if the result contains expected keys
    assert 'planets' in result, "Result should have a 'planets' key"
    assert 'date' in result, "Result should have a 'date' key"
    assert 'latitude' in result, "Result should have a 'latitude' key"
    assert 'longitude' in result, "Result should have a 'longitude' key"
    
    # Check if all expected planets are in the output
    expected_planets = ['mars', 'jupiter barycenter', 'saturn barycenter', 'venus', 'mercury']
    for planet in expected_planets:
        assert planet in result['planets'], f"{planet} should be in the planets data"
    
    # Check if planets have position data
    for planet in expected_planets:
        assert len(result['planets'][planet]) > 0, f"{planet} should have at least one position entry"
        
        # Check if hourly data is present (should be 24 entries for a day)
        assert len(result['planets'][planet]) == 24, f"{planet} should have 24 hourly entries"
        
        # Check data format and ranges
        for position in result['planets'][planet]:
            assert 'time' in position, f"Each position entry should have a 'time' field"
            assert 'altitude' in position, f"Each position entry should have an 'altitude' field"
            assert 'azimuth' in position, f"Each position entry should have an 'azimuth' field"
            
            # Check value ranges
            assert -90 <= position['altitude'] <= 90, f"Altitude should be between -90 and 90 degrees, got {position['altitude']}"
            assert 0 <= position['azimuth'] < 360, f"Azimuth should be between 0 and 360 degrees, got {position['azimuth']}"

    print("✅ test_calculate_planet_positions passed!")

def test_invalid_date():
    """
    Manually test if an invalid date format raises an error.
    """
    try:
        calculate_planet_positions("invalid-date", 53.3811, -1.4701)
        assert False, "Expected a ValueError for an invalid date but none was raised"
    except ValueError as e:
        # Check if the error message contains specific text about date format
        assert "time data" in str(e) and "does not match format" in str(e), \
            f"Expected ValueError about date format, got: {str(e)}"
        print("✅ test_invalid_date passed (caught ValueError with correct message)")
    except Exception as e:
        assert False, f"Unexpected exception type: {type(e).__name__}, message: {str(e)}"

def test_extreme_coordinates():
    """
    Test if the function handles extreme latitude/longitude values.
    """
    # Test North Pole
    try:
        result = calculate_planet_positions("2025-03-15", 90.0, 0.0)
        assert 'planets' in result, "Result should have a 'planets' key even for extreme coordinates"
        print("✅ test_extreme_coordinates (North Pole) passed!")
    except Exception as e:
        assert False, f"Failed with North Pole coordinates: {str(e)}"
    
    # Test South Pole
    try:
        result = calculate_planet_positions("2025-03-15", -90.0, 0.0)
        assert 'planets' in result, "Result should have a 'planets' key even for extreme coordinates"
        print("✅ test_extreme_coordinates (South Pole) passed!")
    except Exception as e:
        assert False, f"Failed with South Pole coordinates: {str(e)}"
    
    # Test International Date Line
    try:
        result = calculate_planet_positions("2025-03-15", 0.0, 180.0)
        assert 'planets' in result, "Result should have a 'planets' key even for extreme coordinates"
        print("✅ test_extreme_coordinates (Date Line) passed!")
    except Exception as e:
        assert False, f"Failed with Date Line coordinates: {str(e)}"

# Run the tests
if __name__ == "__main__":
    test_calculate_planet_positions()
    test_invalid_date()
    test_extreme_coordinates()