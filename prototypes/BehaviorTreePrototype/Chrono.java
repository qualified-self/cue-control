/*
 * Chronometer class
 * Chronometer/stopwatch class that counts the time passed since started.
 *
 * (c) 2015 Sofian Audry        :: info(@)sofianaudry(.)com
 * (c)      Thomas O Fredericks :: tof(@)t-o-f(.)info
 * (c)      Rob Tillaart
 *
 * Based on code by Sofian Audry:
 * https://github.com/sofian/libinteract/blob/master/trunk/arduino/SuperTimer.h
 * http://accrochages.drone.ws/node/90
 *
 * Rob Tillaart StopWatch library:
 * http://playground.arduino.cc/Code/StopWatchClass
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
class Chrono {

	Chrono() {
		this(true);
	}

  Chrono(boolean startNow) {
	  if (startNow)
	    restart();
	  else {
	    _startTime = _offset = 0;
	    _isRunning = false;
	  }
	}

	void restart() {
		restart(0);
	}

	void restart(long offset) {
	  _offset    = offset;
    resume();
	}

	void stop() {
	  _offset    = elapsed(); // save currently elapsed time
	  _isRunning = false;
	}

	void resume() {
	  _startTime = BehaviorTreePrototype.instance().millis();
	  _isRunning = true;
	}

	void add(long t) {
	  _offset += t;
	}

	boolean isRunning() {
	  return (_isRunning);
	}

	void delay(long time) {
	  time += elapsed();
	  while (!hasPassed(time));
	}

	long elapsed() {
	  return _offset + (_isRunning ? (BehaviorTreePrototype.instance().millis() - _startTime) : 0);
	}

	boolean hasPassed(long timeout)
	{
	  return (elapsed() >= timeout);
	}

	boolean hasPassed(long timeout, boolean restartIfPassed) {
	  if (hasPassed(timeout)) {
	    if (restartIfPassed)
	      restart();
	    return true;
	  }
	  else {
	    return false;
	  }
	}

	float seconds() {
	  return (elapsed() / 1000.0f);
	}

  // Keeps track of start time (in chosen time unit).
  long _startTime;

  // Time offset.
  long _offset;

  // Tells if the chrono is currently running or not.
  boolean _isRunning;
}
