function Z = totransform(TRANSFORM,Y)
 Z = [TRANSFORM.b * Y' * TRANSFORM.T + TRANSFORM.c]';
end
