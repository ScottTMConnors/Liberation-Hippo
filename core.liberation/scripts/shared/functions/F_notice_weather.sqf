// News card: weather report. Returns [title, body, kind].
private _data = ["Weather"] call lrx_getParamData select 1;
private _value = _data select (["Weather"] call lrx_getParamValue);
private _body = format [
	"%1 on %2  ·  daylight %3:00–%4:00<br/>Rain %5%9  ·  Fog %6%9  ·  Wind %7 km/h from %8°",
	_value, worldName, GRLIB_nights_stop, GRLIB_nights_start,
	round (linearConversion [0, 1, rain, 0, 100, true]), round (linearConversion [0, 1, fog, 0, 100, true]),
	round (windStr * 100), round windDir, "%"
];
["Weather report", _body, "info"]
