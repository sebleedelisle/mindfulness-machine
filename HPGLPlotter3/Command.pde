final int COMMAND_MOVE = 0; 
final int COMMAND_DRAW = 1; 
final int COMMAND_DRAW_DIRECT = 2; 
final int COMMAND_RESTART = 3; 
final int COMMAND_FINISH = 4; 
final int COMMAND_VELOCITY = 5; 
final int COMMAND_FORCE = 6; 
final int COMMAND_PEN_CHANGE = 7; 


class Command { 

  int c; 
  int p1, p2;

  Command (int _c, int _p1, int _p2) { 

    set(_c, _p1, _p2);
  }

  Command (int _c, float _p1, float _p2) { 
    set(_c, round(_p1), round(_p2)) ;
  }

  void set(int _c, int _p1, int _p2) { 
    c = _c; 
    p1 = _p1; 
    p2 = _p2; 
    //println("CMD : "+c+" "+p1+" "+p2);
  }
};