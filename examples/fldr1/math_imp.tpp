namespace Math
  M_PI := 3.14159

  inline def arclength(ang, rad) : numreg
    using M_PI

    return(ang*rad*M_PI/180)
  end

  inline def arcangle(len, rad) : numreg
    using M_PI

    return(len/rad*180/M_PI)
  end
end
