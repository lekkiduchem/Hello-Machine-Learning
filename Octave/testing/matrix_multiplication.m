x = [5,5,5;0,0,0]; y = [2,1;2,2;2,3];

% SCALARS
printf(" x (%d,%d)  * y (%d,%d)  = (%d,%d) : ", size(x ), size(y ), size(x   * y ));    x   * y
printf(" x'(%d,%d) * y (%d,%d) : UNDEFINED\n",  size(x'), size(y ));                    x'  * y
printf(" x'(%d,%d)  * y'(%d,%d)  = (%d,%d) : ", size(x'), size(y'), size(x   * y'));    x   * y'
printf(" x (%d,%d) * y'(%d,%d) : UNDEFINED\n",  size(x ), size(y'));                    x'  * y'

printf(" x (%d,%d) .* y (%d,%d)  = (%d,%d) : ", size(x ), size(y ), size(x  .* y ));    x  .* y
printf(" x'(%d,%d) .* y (%d,%d)  = (%d,%d) : ", size(x'), size(y ), size(x' .* y ));    x' .* y
printf(" x (%d,%d) .* y'(%d,%d)  = (%d,%d) : ", size(x ), size(y'), size(x  .* y'));    x  .* y'
printf(" x'(%d,%d) .* y'(%d,%d)  = (%d,%d) : ", size(x'), size(y'), size(x' .* y'));    x' .* y'

printf(" y (%d,%d)  * x (%d,%d)  = (%d,%d) : ", size(y ), size(x ), size(y   * x ));    y   * x
printf(" y'(%d,%d) * x (%d,%d) : UNDEFINED\n",  size(y'), size(x ));                    y'  * x
printf(" y (%d,%d) * x'(%d,%d) : UNDEFINED\n",  size(y ), size(x'));                    y   * x'
printf(" y'(%d,%d)  * x'(%d,%d)  = (%d,%d) : ", size(y'), size(x'), size(y'  * x'));    y'  * x'

printf(" y (%d,%d) .* x (%d,%d)  = (%d,%d) : ", size(y ), size(x ), size(y  .* x ));    y  .* x
printf(" y'(%d,%d) .* x (%d,%d)  = (%d,%d) : ", size(y'), size(x ), size(y' .* x ));    y' .* x
printf(" y (%d,%d) .* x'(%d,%d)  = (%d,%d) : ", size(y ), size(x'), size(y  .* x'));    y  .* x'
printf(" y'(%d,%d) .* x'(%d,%d)  = (%d,%d) : ", size(y'), size(x'), size(y' .* x'));    y' .* x'

% 1x3 MATRICIES
% 3x1 MATRICIES
% 3x3 MATRICIES
% UNDEFINED
