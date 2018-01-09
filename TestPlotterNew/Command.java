import java.lang.Math;

class Command { 

  int c; 
  int p1, p2, p3;
  
  Command (int _c, int _p1) { 
    set(_c, _p1, 0, 0);
  }
  Command (int _c, int _p1, int _p2) { 
    set(_c, _p1, _p2, 0);
  }
  Command (int _c, int _p1, int _p2, int _p3) { 
    set(_c, _p1, _p2, _p3);
  }

  Command (int _c, float _p1, float _p2, float _p3) { 
    set(_c, Math.round(_p1), Math.round(_p2), Math.round(_p3)) ;
  }
  Command (int _c, float _p1, float _p2) { 
    set(_c, Math.round(_p1), Math.round(_p2)) ;
  }
  void set(int _c, int _p1, int _p2) { 
    set(_c, _p1, _p2, 0); 
    //println("CMD : "+c+" "+p1+" "+p2);
  }
  void set(int _c, int _p1, int _p2, int _p3) { 
    c = _c; 
    p1 = _p1; 
    p2 = _p2; 
    p3 = _p3;
  }
};