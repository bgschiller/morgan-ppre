library debounce;

import 'dart:async';

Map timeouts = {};

void debounce(int timeoutMS, Function target, List arguments) {
  if(timeouts.containsKey(target)) {
    timeouts[target].cancel();
  }

  Timer timer = new Timer(new Duration(milliseconds: timeoutMS), () {
    Function.apply(target, arguments);
  });

  timeouts[target] = timer;
}