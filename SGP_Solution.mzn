include "globals.mzn";

int: n_groups;                          % The number of groups.
int: n_per_group;                       % The size of each group.
int: n_rounds;                          % The number of rounds.

int: n_golfers = n_groups * n_per_group;

set of int: groups = 1..n_groups;
set of int: group = 1..n_per_group;
set of int: rounds = 1..n_rounds;
set of int: golfers = 1..n_golfers;

array [rounds, groups, group] of var golfers: round_group_of_golfer;


% Each member of each group must be distinct.
%
%  C11 = ( V[i=0,j-0;i<n_groups,j<n_per_group]wij ) 
%  C12 = ( V[r=1]V[i=0,j-0;i<n_groups,j<n_per_group]V[t<-D,t*<-D/{t}](Xwijt-->ㄱXwijt*) )
%  C1 = C11 ^ C12
constraint
    forall (r in rounds) (
        alldifferent (g in groups, i in group) (round_group_of_golfer[r, g, i])
    );


%Kemi me e check kete kontraint
% We also break some symmetry
% here by strictly ordering each group.
%
constraint
    forall (r in rounds, g in groups, i in group where i < n_per_group) (
       round_group_of_golfer[r, g, i] > round_group_of_golfer[r, g, i + 1]
   );




%(Xwij ^ Xwik)-->	ㄱ(Xyij ^ Xyik)
% Each pair can play together at most once.
%    
constraint
    forall (r1, r2 in rounds where r1!=r2) (  
      forall(g1, g2 in groups)(
      sum (i1, j1, i2, j2 in group where (i1 < j1/\i2<j2)) (
                %  ( [r1,g1,i1]=[r2,g2,i2] ^ [r1,g1,j1]=[r2,g2,j2] )
              bool2int(
              round_group_of_golfer[r1, g1, i1] =round_group_of_golfer[r2, g2, i2]  /\  
              round_group_of_golfer[r1, g1, j1] = round_group_of_golfer[r2, g2, j2]
              )+
              bool2int(
              round_group_of_golfer[r1, g1, i1] =round_group_of_golfer[r2, g2, j2]  /\  
              round_group_of_golfer[r1, g1, j1] = round_group_of_golfer[r2, g2, i2]
              )
          )<1
        )    
    );

solve satisfy;

output [
    "Social golfers:\n\n", 
    "Groups        : ", show(n_groups), "\n", 
    "No. per group : ", show(n_per_group), "\n",
    "No. of rounds : ", show(n_rounds), "\n"
] 
++ 
[
    ( if g = 1 /\ i = 1 then "\nround " ++ show(r) ++ ":" else "" endif) ++
    ( if i = 1 then "   " else " " endif) ++
    show_int(2, round_group_of_golfer[r, g, i]) 
    |  r in rounds, g in groups, i in group
];

%-----------------------------------------------------------------------------%
%-----------------------------------------------------------------------------%
