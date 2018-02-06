import React from 'react';
import moment from 'moment';

import cn from 'classnames';

const PlacePickerJumbotron = (props) => {
  const { places, isLuggageRequired, } = props.direction;
  const economPlaces = places.filter((place) => place.type === 'econom');
  const businessPlaces = places.filter((place) => place.type === 'business');
  const togglePlace = (e) => {
    props.togglePlace(Number(e.target.innerHTML), props.directionName);
  };
  const toggleLuggage = (e) => {
    props.toggleLuggage(props.directionName);
  };
  const placeRenderer = (place) => {
    if (place.isPermanently || moment() < place.expiresAt) {
      return (
        <span className="mx-1" key={place.number}>
          {place.number}
        </span>
      );
    } else {
      return (
        <a
          key={place.number}
          className={cn(
            'mx-1',
            {
              'available-place': place.available,
            },
            {
              'booked-place': !place.available,
            }
          )}
          onClick={togglePlace}
        >
          {place.number}
        </a>
      );
    }
  };
  return (
    <div className="jumbotron">
      <p className="lead text-center">Choose available places:</p>
      <div className="w-50">
        <p>Econom places:</p>
        {economPlaces.map(placeRenderer)}
      </div>
      <div>
        <p>Business places:</p>
        {businessPlaces.map(placeRenderer)}
      </div>
      <div className="form-check mt-4">
        <input
          type="checkbox"
          className="form-check-input"
          id="luggageCheck"
          // value={isLuggage}
          onChange={toggleLuggage}
        />
        <label htmlFor="luggageCheck" className="form-check-label">
          Check if you have luggage
        </label>
      </div>
      {isLuggageRequired && (
        <div className="form-group">
          <input
            type="text"
            className="form-control"
            placeholder="Input your luggage weight, kg"
            required
          />
          Max amount: {props.luggageLimit}kg!!
        </div>
      )}
    </div>
  );
};

export default PlacePickerJumbotron;
