d = 1; % d - display; toggle to display results of multiplication

x = [ 1,  1,  1 ;
      1,  1,  4 ]

y = [ 2, 1 ;
      2, 2 ;
      2, 3 ]

printf(" x (%d,%d)  * y (%d,%d)  = (%d,%d) | ", size(x ), size(y ), size(x  * y  )), ifelse(d, x  * y  , "")  % x (2,3)  * y (3,2) = (2,2)
printf(" y (%d,%d)  * x (%d,%d)  = (%d,%d) | ", size(y ), size(x ), size(y  * x  )), ifelse(d, y  * x  , "")  % y (3,2)  * x (2,3) = (3,3)
printf(" x'(%d,%d)  * y'(%d,%d)  = (%d,%d) | ", size(x'), size(y'), size(x' * y' )), ifelse(d, x' * y' , "")  % x'(3,2)  * y'(2,3) = (3,3)
printf(" y'(%d,%d)  * x'(%d,%d)  = (%d,%d) | ", size(y'), size(x'), size(y' * x' )), ifelse(d, y' * x' , "")  % y'(2,3)  * x'(3,2) = (2,2)
printf(" x'(%d,%d) .* y (%d,%d)  = (%d,%d) | ", size(x'), size(y ), size(x' .* y )), ifelse(d, x' .* y , "")  % x'(3,2) .* y (3,2) = (3,2)
printf(" x (%d,%d) .* y'(%d,%d)  = (%d,%d) | ", size(x ), size(y'), size(x  .* y')), ifelse(d, x  .* y', "")  % x (2,3) .* y'(2,3) = (2,3)
printf(" y'(%d,%d) .* x (%d,%d)  = (%d,%d) | ", size(y'), size(x ), size(y' .* x )), ifelse(d, y' .* x , "")  % y'(2,3) .* x (2,3) = (2,3)
printf(" y (%d,%d) .* x'(%d,%d)  = (%d,%d) | ", size(y ), size(x'), size(y  .* x')), ifelse(d, y  .* x', "")  % y (3,2) .* x'(3,2) = (3,2)

% UNDEFINED
printf(" x (%d,%d)  * y'(%d,%d) : UNDEFINED\n", size(x ), size(y')); % x  * y'
printf(" x'(%d,%d)  * y (%d,%d) : UNDEFINED\n", size(x'), size(y )); % x' * y
printf(" y (%d,%d)  * x'(%d,%d) : UNDEFINED\n", size(y ), size(x')); % y  * x'
printf(" y'(%d,%d)  * x (%d,%d) : UNDEFINED\n", size(y'), size(x )); % y' * x
printf(" x (%d,%d) .* y (%d,%d) : UNDEFINED\n", size(x ), size(y )); % x  .* y
printf(" y (%d,%d) .* x (%d,%d) : UNDEFINED\n", size(y ), size(x )); % y  .* x
printf(" x'(%d,%d) .* y'(%d,%d) : UNDEFINED\n", size(x'), size(y')); % x' .* y'
printf(" y'(%d,%d) .* x'(%d,%d) : UNDEFINED\n", size(y'), size(x')); % y' .* x'
  % x (2,3)  * y'(2,3) : UNDEFINED
  % x'(3,2)  * y (3,2) : UNDEFINED
  % y (3,2)  * x'(3,2) : UNDEFINED
  % y'(2,3)  * x (2,3) : UNDEFINED
  % x (2,3) .* y (3,2) : UNDEFINED
  % y (3,2) .* x (2,3) : UNDEFINED
  % x'(3,2) .* y'(2,3) : UNDEFINED
  % y'(2,3) .* x'(3,2) : UNDEFINED


% * - matrix multiplication - operation is allowed only for matricies where first matrix have same amount of columns as second one has the rows. The result of multiplication [n x m] * [m x p] = [n x p]
% .* - Element-by-element multiplication. If both operands are matrices, the number of rows and columns must both agree. [n x m] * [n x m] = [n x m]
