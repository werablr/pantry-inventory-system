-- Fix recipe_ingredients table boolean/integer issues
-- Column structure: recipe_id, ingredient_id, amount, unit, preparation, optional
-- optional should be boolean (true/false), others should stay as-is

-- First, fix specific known patterns
s/VALUES(\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),0)/VALUES(\1,\2,\3,\4,\5,false)/g
s/VALUES(\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),1)/VALUES(\1,\2,\3,\4,\5,true)/g

-- Fix other boolean columns that should be true/false
s/would_make_again BOOLEAN[^,]*/would_make_again BOOLEAN/g
s/,1,/,true,/g
s/,0,/,false,/g
s/,1)/,true)/g  
s/,0)/,false)/g
