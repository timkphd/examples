#!python3
'''
This demonstrates the new map rendering capabilities in Pythonista 3.3 by generating a satellite image from your current location or some other location, if you prefer not to use your device's GPS.

You need to allow location access for Pythonista for this script to work in "my location" mode.
'''

import location
import time
import photos
import appex
import ui
import dialogs
from random import randrange

location_options = [
	{'title': 'My Location', 'coords': (0, 0)},
	{'title': 'Berlin, Brandenburg Gate', 'coords': (52.516272, 13.377722)},
	{'title': 'Paris, Eiffel Tower', 'coords': (48.858222, 2.2945)},
	# Feel free to add your own favorite locations here... You can usually find the coordinates of famous landmarks on Wikipedia.
]
def get_location():
	location.start_updates()
	time.sleep(1)
	loc = location.get_location()
	location.stop_updates()
	if loc:
		return loc['latitude'], loc['longitude']

def main():
	opt = dialogs.list_dialog('Select Mode', location_options)
	if opt is None:
		return
	elif opt['coords'] == (0, 0):
		# Use current location
		loc = get_location()
	else:
		loc = opt['coords']
	if loc:
		w, h = 540, 540 # Size of the image (points)
		map_w, map_h = 500, 500 # Size of the map (meters)
		lat, lng = loc
		img = location.render_map_snapshot(lat, lng, width=map_w, height=map_h, img_width=w, img_height=h, map_type='satellite')
		if not img:
			print('Failed not render map')
			return
		jpeg_data = img.to_jpeg()
		with open('.temp.jpg', 'wb') as f:
			f.write(jpeg_data)
		img.show()
		s = dialogs.alert('Save to Photos?', 'Do you want to save the image to your photo library?', 'Save to Photos')
		if s == 1:
			photos.create_image_asset('.temp.jpg')
	else:
		print('Cannot determine location. Try again later, or allow location access for Pythonista in the Settings app.')

if __name__ == '__main__':
	main()


