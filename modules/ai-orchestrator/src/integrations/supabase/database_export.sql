PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE recipes (
    recipe_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    servings INTEGER,
    prep_time_minutes INTEGER,
    cook_time_minutes INTEGER,
    total_time_minutes INTEGER,
    difficulty_level TEXT CHECK(difficulty_level IN ('Easy', 'Medium', 'Hard')),
    cuisine_type TEXT,
    meal_type TEXT CHECK(meal_type IN ('Breakfast', 'Lunch', 'Dinner', 'Snack', 'Dessert')),
    date_created DATE DEFAULT (date('now')),
    date_last_made DATE,
    times_made INTEGER DEFAULT 0,
    source TEXT,
    notes TEXT
);
INSERT INTO recipes VALUES(1,'Balsamic-Glazed Pork Tenderloin with Roasted Carrots & Green Beans','Tender pork tenderloin with a tangy balsamic glaze',2,20,20,40,'Medium','American','Dinner','2025-05-31',NULL,0,'Personal Collection','Great for date night or special dinner');
INSERT INTO recipes VALUES(2,'Balsamic-Glazed Pork Tenderloin with Roasted Carrots & Green Beans','Tender pork tenderloin with a tangy balsamic glaze',2,20,20,40,'Medium','American','Dinner','2025-05-31',NULL,0,'Personal Collection','Great for date night or special dinner');
INSERT INTO recipes VALUES(3,'Turkey Breakfast Sausage with Fried Egg & Fruit','Complete breakfast with sausage, eggs, fruit, and optional English muffin',2,5,15,20,'Easy','American','Breakfast','2025-06-04',NULL,0,'Personal Collection','Simple breakfast with multiple components');
CREATE TABLE ingredients (
    ingredient_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    category TEXT, -- 'Protein', 'Vegetable', 'Spice', etc.
    common_unit TEXT -- 'cups', 'tablespoons', 'pounds', etc.
);
INSERT INTO ingredients VALUES(1,'pork tenderloin','Protein','lb');
INSERT INTO ingredients VALUES(2,'balsamic vinegar','Condiment','tbsp');
INSERT INTO ingredients VALUES(3,'olive oil','Oil','tbsp');
INSERT INTO ingredients VALUES(4,'Dijon mustard','Condiment','tsp');
INSERT INTO ingredients VALUES(5,'garlic','Vegetable','cloves');
INSERT INTO ingredients VALUES(6,'salt','Seasoning','tsp');
INSERT INTO ingredients VALUES(7,'black pepper','Seasoning','tsp');
INSERT INTO ingredients VALUES(15,'turkey breakfast sausage','Protein',NULL);
INSERT INTO ingredients VALUES(16,'large eggs','Protein',NULL);
INSERT INTO ingredients VALUES(17,'strawberries','Fruit',NULL);
INSERT INTO ingredients VALUES(18,'orange','Fruit',NULL);
INSERT INTO ingredients VALUES(19,'whole grain English muffins','Grain',NULL);
INSERT INTO ingredients VALUES(20,'cranberry juice','Beverage',NULL);
INSERT INTO ingredients VALUES(21,'orange juice','Beverage',NULL);
INSERT INTO ingredients VALUES(22,'milk','Dairy',NULL);
INSERT INTO ingredients VALUES(23,'butter','Dairy',NULL);
CREATE TABLE recipe_ingredients (
    recipe_id INTEGER,
    ingredient_id INTEGER,
    amount REAL,
    unit TEXT,
    preparation TEXT, -- 'diced', 'minced', 'chopped', etc.
    optional BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (recipe_id, ingredient_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);
INSERT INTO recipe_ingredients VALUES(1,1,1.0,'lb','¾ to 1 lb',0);
INSERT INTO recipe_ingredients VALUES(1,2,2.0,'tbsp','',0);
INSERT INTO recipe_ingredients VALUES(1,3,1.0,'tbsp','',0);
INSERT INTO recipe_ingredients VALUES(1,4,1.0,'tsp','',0);
INSERT INTO recipe_ingredients VALUES(1,5,2.0,'cloves','minced',0);
INSERT INTO recipe_ingredients VALUES(1,6,0.5,'tsp','',0);
INSERT INTO recipe_ingredients VALUES(1,7,0.25,'tsp','',0);
INSERT INTO recipe_ingredients VALUES(3,23,1.0,'tbsp',NULL,0);
INSERT INTO recipe_ingredients VALUES(3,20,8.0,'oz',NULL,0);
INSERT INTO recipe_ingredients VALUES(3,16,2.0,'pieces','fried',0);
INSERT INTO recipe_ingredients VALUES(3,22,8.0,'oz',NULL,0);
INSERT INTO recipe_ingredients VALUES(3,18,1.0,'pieces','peeled and sliced',0);
INSERT INTO recipe_ingredients VALUES(3,21,8.0,'oz',NULL,0);
INSERT INTO recipe_ingredients VALUES(3,17,1.0,'cup','fresh',0);
INSERT INTO recipe_ingredients VALUES(3,15,6.0,'links','cooked',0);
INSERT INTO recipe_ingredients VALUES(3,19,1.0,'pieces','toasted',0);
CREATE TABLE instructions (
    instruction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    recipe_id INTEGER NOT NULL,
    step_number INTEGER NOT NULL,
    instruction_text TEXT NOT NULL,
    time_minutes INTEGER, -- time for this specific step
    temperature INTEGER, -- oven temp if applicable
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    UNIQUE(recipe_id, step_number)
);
INSERT INTO instructions VALUES(1,1,1,'Mix balsamic vinegar, olive oil, garlic, mustard, salt, and pepper. Coat the pork and marinate for 15–30 minutes (or up to overnight).',20,NULL);
INSERT INTO instructions VALUES(2,1,2,'Preheat oven to 400°F. Sear pork in a hot oven-safe skillet for 2–3 minutes per side until browned.',6,NULL);
INSERT INTO instructions VALUES(3,1,3,'Transfer skillet to the oven and roast for 15–20 minutes, or until internal temp reaches 145°F.',18,NULL);
INSERT INTO instructions VALUES(4,1,4,'Rest 5 minutes before slicing.',5,NULL);
INSERT INTO instructions VALUES(5,1,5,'Slice pork and serve. Drizzle with extra balsamic.',1,NULL);
CREATE TABLE recipe_media (
    media_id INTEGER PRIMARY KEY AUTOINCREMENT,
    recipe_id INTEGER NOT NULL,
    media_type TEXT CHECK(media_type IN ('video', 'image', 'pdf')),
    url TEXT,
    local_file_path TEXT,
    description TEXT,
    platform TEXT, -- 'YouTube', 'TikTok', 'Local', etc.
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) ON DELETE CASCADE
);
CREATE TABLE recipe_feedback (
    feedback_id INTEGER PRIMARY KEY AUTOINCREMENT,
    recipe_id INTEGER NOT NULL,
    date_tried DATE NOT NULL,
    rating INTEGER CHECK(rating >= 1 AND rating <= 5),
    taste_rating INTEGER CHECK(taste_rating >= 1 AND taste_rating <= 5),
    difficulty_rating INTEGER CHECK(difficulty_rating >= 1 AND difficulty_rating <= 5),
    would_make_again BOOLEAN,
    modifications_made TEXT,
    what_worked TEXT,
    what_to_change TEXT,
    family_feedback TEXT,
    cooking_notes TEXT,
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) ON DELETE CASCADE
);
INSERT INTO recipe_feedback VALUES(1,1,'25 may 25',5,5,1,1,NULL,'Cutting into medalions before cooking',NULL,NULL,NULL);
CREATE TABLE shopping_lists (
    list_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    date_created DATE DEFAULT (date('now')),
    for_week_of DATE,
    completed BOOLEAN DEFAULT FALSE
);
CREATE TABLE shopping_list_items (
    item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    list_id INTEGER NOT NULL,
    ingredient_id INTEGER,
    custom_item TEXT, -- for items not in ingredients table
    amount REAL,
    unit TEXT,
    purchased BOOLEAN DEFAULT FALSE,
    store_section TEXT, -- 'Produce', 'Dairy', 'Meat', etc.
    FOREIGN KEY (list_id) REFERENCES shopping_lists(list_id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);
CREATE TABLE meal_plans (
    plan_id INTEGER PRIMARY KEY AUTOINCREMENT,
    week_start_date DATE NOT NULL,
    notes TEXT
);
CREATE TABLE planned_meals (
    planned_meal_id INTEGER PRIMARY KEY AUTOINCREMENT,
    plan_id INTEGER NOT NULL,
    recipe_id INTEGER,
    meal_date DATE NOT NULL,
    meal_type TEXT CHECK(meal_type IN ('Breakfast', 'Lunch', 'Dinner', 'Snack')),
    servings_planned INTEGER DEFAULT 1,
    notes TEXT,
    FOREIGN KEY (plan_id) REFERENCES meal_plans(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id)
);
CREATE TABLE conversation_memory (
    memory_id INTEGER PRIMARY KEY AUTOINCREMENT,
    date_created DATE DEFAULT (date('now')),
    memory_type TEXT CHECK(memory_type IN ('preference', 'context', 'instruction', 'feedback')),
    topic TEXT, -- 'cooking', 'ingredients', 'planning', etc.
    content TEXT NOT NULL,
    importance INTEGER CHECK(importance >= 1 AND importance <= 5) DEFAULT 3,
    last_referenced DATE,
    active BOOLEAN DEFAULT TRUE
, project_id INTEGER REFERENCES projects(project_id));
INSERT INTO conversation_memory VALUES(1,'2025-05-31','instruction','system','User prefers structured database over text files for recipe management',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(2,'2025-05-31','preference','cooking','User is comfortable with Excel/Numbers and wants to learn SQLite',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(3,'2025-05-31','context','planning','User creates weekly menus and prints them by day and meal with video links',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(4,'2025-05-31','instruction','tagging','Database has complete auto-tagging system built-in. Use auto_tag_suggestions view to see what tags should be applied to recipes.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(5,'2025-05-31','instruction','workflow','When user uploads recipe: 1) Add recipe to database 2) Check auto_tag_suggestions for that recipe_id 3) Apply high-confidence tags automatically',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(6,'2025-05-31','preference','tagging','User wants fully automated tagging - no manual tag assignment required',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(7,'2025-05-31','instruction','views','Use recipe_with_tags view to see recipes with their applied tags. Use auto_tag_suggestions to see what tags should be auto-applied.',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(8,'2025-06-02','context','system','CRITICAL: SQLite .db files CAN be uploaded to Claude Desktop via + button. Previous conflicting information was incorrect. User successfully uploaded all_things_food.db file multiple times.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(9,'2025-06-02','context','pantry','Successfully imported complete KitchenPal inventory (306 items) using optimized bulk INSERT. Much faster than individual INSERTs. User has full pantry inventory loaded with proper data transformation.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(10,'2025-06-02','context','ingredients','Created comprehensive ingredient mapping system with master_ingredients table, pantry_mapping_approvals workflow, and manual approval process. User prefers to approve ALL mappings manually - no automatic fuzzy matching.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(11,'2025-06-02','context','workflow','Key insight: User stores recipes long-term but only needs ingredient checking when moving recipes to active queue for cooking. This dramatically reduces maintenance overhead.',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(12,'2025-06-02','context','learning','User learned SQLite basics using Excel analogies: Database = Workbook, Tables = Worksheets, Browse Data = seeing rows/columns. Prefers simple explanations without SQL complexity.',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(13,'2025-06-02','context','success','Successfully approved first ingredient mapping: Dijon mustard pantry item linked to dijon_mustard master ingredient. User understands the process and can repeat for other ingredients.',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(14,'2025-06-02','context','pantry_insight','User insight: Pantry ingredients are mostly stable (same brands, same products). Only quantities change after cooking/shopping. Real variety comes from NEW RECIPES, not pantry changes.',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(15,'2025-06-02','context','next_session','For next conversation: 1) Continue approving ingredient mappings, 2) Build recipe queue system, 3) Create new recipe ingredient checker, 4) Develop shopping list generator, 5) Test complete workflow with second recipe.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(16,'2025-06-03','instruction','next_session_priority','CRITICAL FIRST STEP: Run the alternative_names_system artifact to create ingredient_alternative_names table and populate with common variations. Then run complete_approval_workflow to bulk approve current mappings. This creates the auto-approval system.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(17,'2025-06-03','context','system_architecture','Built complete auto-approval architecture: ingredient_alternative_names table stores known variations, auto_approval_candidates view identifies matches, trigger automatically adds manual approvals to cross-reference. Every approval teaches system for future.',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(18,'2025-06-03','instruction','workflow_sequence','EXACT SEQUENCE: 1) Run alternative_names_system SQL in DB Browser, 2) Run complete_approval_workflow SQL, 3) Check results with provided queries, 4) Continue to recipe queue system. User has artifacts ready to execute.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(19,'2025-06-03','context','user_understanding','User fully grasps the learning system concept: initial high manual work → system learns patterns → eventual 95%+ auto-approval. User wants automated cross-reference updates when manual approvals are made. System designed accordingly.',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(20,'2025-06-03','instruction','immediate_next_step','CRITICAL: User ready to run analyze_remaining_75 query to see what categories remain in the 75 pending items. This will guide creation of final master ingredients batch to reach 70%+ auto-approval rate.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(21,'2025-06-03','context','breakthrough_achieved','MAJOR SUCCESS: Auto-approval system working perfectly. Went from 15.3% to 45.8% auto-approval in single execution. Learning system operational with 30+ master ingredients added. User experienced the learning multiplier effect firsthand.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(22,'2025-06-03','instruction','system_architecture','Current system: ingredient_alternative_names table (no FK constraints), comprehensive master ingredients for common items, auto-approval logic with exact/contains matching, learning trigger for future manual approvals. All components working.',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(23,'2025-06-03','context','user_satisfaction','User saw dramatic results and understands the learning system value. Excited about the breakthrough but needs break before final push. Ready to continue with remaining 75 items analysis when returning.',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(24,'2025-06-04','context','ingredients_project_completion','INGREDIENTS PROJECT COMPLETED: 4 strategic phases executed, 70+ master ingredients created, learning system operational with 1.4x multiplier effect. Handles real 306-item inventory with brand recognition (Banza, Campbells, etc.). Auto-approval architecture fully functional.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(25,'2025-06-04','context','recipe_import_success','RECIPE IMPORT SYSTEM PROVEN: Successfully imported Turkey Sausage Breakfast recipe with 9 ingredients, full data linking, auto-tagging capability. Text format perfectly compatible with bulk import system.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(26,'2025-06-04','context','recipe_library_ready','User has HUNDREDS of recipes in text format ready for bulk import. Format is clean and structured (see Turkey Sausage example). CSV conversion strategy designed. Ready for Stage 1: Recipe Library bulk import.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(27,'2025-06-04','context','ingredients_foundation_complete','Ingredients automation project is COMPLETE and operational. Learning system proven. 70+ master ingredients cover major categories. System ready to handle recipe ingredients automatically.',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(28,'2025-06-04','context','current_status','CURRENT STATUS: Ingredients project done. Single recipe import successful. User ready for bulk recipe import vs. Phase 5 ingredient expansion decision. Recipe Queue Stage 1 architecture validated.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(29,'2025-06-04','instruction','next_priorities','IMMEDIATE NEXT: 1) Assess Phase 5 need (turkey sausage, berries, citrus, English muffins, fruit juices) vs. proceeding with bulk recipe import, 2) If bulk import: CSV conversion of hundreds of recipes, 3) Stage 1 Recipe Library completion',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(30,'2025-06-04','context','recipe_format_perfect','Users text recipe format is EXCELLENT for bulk processing. Clear structure, ingredient lists, timing data. Much better than typical CSV exports. Text-to-CSV conversion will be clean and efficient.',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(31,'2025-06-04','context','learning_system_mastery','Learning system architecture mastered: ingredient_alternative_names table, auto-approval logic, manual approval triggers, learning multiplier effects. Every approval teaches system for future automation.',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(32,'2025-06-05','context','database_integration_success','SQLite MCP integration fully restored and operational. Database accessible across all sessions without file uploads. Method: uvx + mcp-server-sqlite pointing to /Users/brianrogers/sqlite-mcp-project/database/All_Things_Food_database.db. Configuration method documented in VS Code project.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(33,'2025-06-05','instruction','database_expansion_vision','USER VISION: Expand All Things Food database to support ALL life projects - work, personal, home improvement, financial planning, etc. Leverage proven automation patterns (learning systems, approval workflows, auto-tagging) for comprehensive "All Things Brian" project management system.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(34,'2025-06-05','context','current_food_system_status','Ingredients automation: 129 approved, 8 pending (94% automation rate). Recipe system: Single recipe tested successfully, ready for bulk import of hundreds of recipes. Learning system operational with alternative names table and auto-approval triggers.',4,NULL,1,1);
INSERT INTO conversation_memory VALUES(35,'2025-06-05','instruction','integration_method_proven','SQLite + MCP + VS Code project structure is the proven method for persistent database access. No more file uploads needed. This architecture can scale to support multiple databases and project domains using same integration approach.',5,NULL,1,1);
INSERT INTO conversation_memory VALUES(36,'2025-06-05','context','technical_setup_working','MCP server configuration: uvx command with mcp-server-sqlite, database path in sqlite-mcp-project/database/ folder, Claude Desktop config pointing to All_Things_Food_database.db. Full integration operational with 26 tables accessible.',4,NULL,1,1);
CREATE TABLE user_preferences (
    preference_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT NOT NULL, -- 'dietary', 'cooking', 'planning', etc.
    preference_key TEXT NOT NULL,
    preference_value TEXT NOT NULL,
    date_updated DATE DEFAULT (date('now')),
    UNIQUE(category, preference_key)
);
INSERT INTO user_preferences VALUES(1,'dietary','restrictions','None','2025-05-31');
INSERT INTO user_preferences VALUES(2,'cooking','skill_level','Intermediate','2025-05-31');
INSERT INTO user_preferences VALUES(3,'cooking','preferred_cuisines','Italian, Asian, American','2025-05-31');
INSERT INTO user_preferences VALUES(4,'planning','default_servings','4','2025-05-31');
INSERT INTO user_preferences VALUES(5,'planning','meal_prep_day','Sunday','2025-05-31');
CREATE TABLE tags (
    tag_id INTEGER PRIMARY KEY AUTOINCREMENT,
    tag_name TEXT UNIQUE NOT NULL,
    category TEXT,
    description TEXT
);
INSERT INTO tags VALUES(1,'pan_seared','cooking_method','Seared in a pan or skillet');
INSERT INTO tags VALUES(2,'baked','cooking_method','Cooked in the oven');
INSERT INTO tags VALUES(3,'roasted','cooking_method','Roasted in oven at high heat');
INSERT INTO tags VALUES(4,'grilled','cooking_method','Cooked on grill or barbecue');
INSERT INTO tags VALUES(5,'slow_cooked','cooking_method','Slow cooker or long braising');
INSERT INTO tags VALUES(6,'pressure_cooker','cooking_method','Instant pot or pressure cooker');
INSERT INTO tags VALUES(7,'no_cook','cooking_method','No cooking required');
INSERT INTO tags VALUES(8,'one_pot','cooking_method','Single pot or pan meal');
INSERT INTO tags VALUES(9,'under_15_min','time','Ready in 15 minutes or less');
INSERT INTO tags VALUES(10,'under_30_min','time','Ready in 30 minutes or less');
INSERT INTO tags VALUES(11,'under_60_min','time','Ready in 1 hour or less');
INSERT INTO tags VALUES(12,'quick_weeknight','time','Perfect for busy weeknights');
INSERT INTO tags VALUES(13,'weekend_project','time','More involved weekend cooking');
INSERT INTO tags VALUES(14,'date_night','occasion','Romantic dinner for two');
INSERT INTO tags VALUES(15,'family_dinner','occasion','Family-friendly meal');
INSERT INTO tags VALUES(16,'meal_prep','occasion','Good for batch cooking');
INSERT INTO tags VALUES(17,'party_food','occasion','Great for entertaining');
INSERT INTO tags VALUES(18,'holiday','occasion','Special holiday recipe');
INSERT INTO tags VALUES(19,'comfort_food','occasion','Cozy comfort meal');
INSERT INTO tags VALUES(20,'elegant','occasion','Sophisticated presentation');
INSERT INTO tags VALUES(21,'gluten_free','dietary','No gluten ingredients');
INSERT INTO tags VALUES(22,'dairy_free','dietary','No dairy products');
INSERT INTO tags VALUES(23,'vegetarian','dietary','No meat or fish');
INSERT INTO tags VALUES(24,'vegan','dietary','No animal products');
INSERT INTO tags VALUES(25,'low_carb','dietary','Low carbohydrate content');
INSERT INTO tags VALUES(26,'keto','dietary','Ketogenic diet friendly');
INSERT INTO tags VALUES(27,'paleo','dietary','Paleo diet compliant');
INSERT INTO tags VALUES(28,'healthy','dietary','Nutritious and balanced');
INSERT INTO tags VALUES(29,'spring','season','Great for spring');
INSERT INTO tags VALUES(30,'summer','season','Perfect for hot weather');
INSERT INTO tags VALUES(31,'fall','season','Autumn flavors');
INSERT INTO tags VALUES(32,'winter','season','Warming winter dish');
INSERT INTO tags VALUES(33,'easy','convenience','Simple to make');
INSERT INTO tags VALUES(34,'beginner_friendly','convenience','Good for cooking novices');
INSERT INTO tags VALUES(35,'minimal_cleanup','convenience','Easy to clean up');
INSERT INTO tags VALUES(36,'make_ahead','convenience','Can be prepared in advance');
INSERT INTO tags VALUES(37,'freezer_friendly','convenience','Freezes well');
INSERT INTO tags VALUES(38,'leftover_friendly','convenience','Good reheated');
INSERT INTO tags VALUES(39,'pork','protein','Contains pork');
INSERT INTO tags VALUES(40,'chicken','protein','Contains chicken');
INSERT INTO tags VALUES(41,'beef','protein','Contains beef');
INSERT INTO tags VALUES(42,'fish','protein','Contains fish');
INSERT INTO tags VALUES(43,'balsamic','flavor','Uses balsamic vinegar');
INSERT INTO tags VALUES(44,'tenderloin','cut','Tenderloin cut of meat');
INSERT INTO tags VALUES(45,'garlic','flavor','Contains garlic');
INSERT INTO tags VALUES(46,'mustard','flavor','Contains mustard');
CREATE TABLE recipe_tags (
    recipe_id INTEGER,
    tag_id INTEGER,
    confidence INTEGER DEFAULT 100,
    auto_applied BOOLEAN DEFAULT FALSE,
    date_added DATE DEFAULT (date('now')),
    PRIMARY KEY (recipe_id, tag_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);
INSERT INTO recipe_tags VALUES(1,14,100,1,'2025-05-31');
INSERT INTO recipe_tags VALUES(1,39,100,1,'2025-05-31');
INSERT INTO recipe_tags VALUES(1,43,100,1,'2025-05-31');
INSERT INTO recipe_tags VALUES(1,44,100,1,'2025-05-31');
CREATE TABLE tagging_rules (
    rule_id INTEGER PRIMARY KEY AUTOINCREMENT,
    rule_name TEXT NOT NULL,
    condition_type TEXT CHECK(condition_type IN ('ingredient', 'keyword', 'time', 'servings', 'instruction', 'name')),
    condition_value TEXT NOT NULL,
    tag_name TEXT NOT NULL,
    confidence INTEGER DEFAULT 100,
    active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_date DATE DEFAULT (date('now'))
);
INSERT INTO tagging_rules VALUES(1,'Quick meals under 30','time','<=30','under_30_min',100,1,'Any recipe 30 minutes or under','2025-05-31');
INSERT INTO tagging_rules VALUES(2,'Very quick meals','time','<=15','under_15_min',100,1,'Super fast recipes','2025-05-31');
INSERT INTO tagging_rules VALUES(3,'Quick weeknight eligible','time','<=25','quick_weeknight',90,1,'Fast enough for weeknights','2025-05-31');
INSERT INTO tagging_rules VALUES(4,'Weekend projects','time','>120','weekend_project',85,1,'Long cooking projects','2025-05-31');
INSERT INTO tagging_rules VALUES(5,'Searing detection','keyword','sear|seared|skillet|pan-sear','pan_seared',95,1,'Detects searing methods','2025-05-31');
INSERT INTO tagging_rules VALUES(6,'Baking detection','keyword','baked|baking|oven','baked',90,1,'Detects oven baking','2025-05-31');
INSERT INTO tagging_rules VALUES(7,'Roasting detection','keyword','roast|roasted','roasted',95,1,'Detects roasting','2025-05-31');
INSERT INTO tagging_rules VALUES(8,'Grilling detection','keyword','grill|grilled|barbecue|bbq','grilled',95,1,'Detects grilling','2025-05-31');
INSERT INTO tagging_rules VALUES(9,'Slow cooking detection','keyword','slow.cook|crockpot|braised|stew','slow_cooked',95,1,'Detects slow cooking','2025-05-31');
INSERT INTO tagging_rules VALUES(10,'One pot detection','keyword','one.pot|one.pan|sheet.pan','one_pot',90,1,'Single vessel cooking','2025-05-31');
INSERT INTO tagging_rules VALUES(11,'Date night portions','servings','<=2','date_night',75,1,'Small portions suggest romantic meal','2025-05-31');
INSERT INTO tagging_rules VALUES(12,'Family meal portions','servings','>=4','family_dinner',80,1,'Large portions for families','2025-05-31');
INSERT INTO tagging_rules VALUES(13,'Party portions','servings','>=8','party_food',85,1,'Large batch for entertaining','2025-05-31');
INSERT INTO tagging_rules VALUES(14,'Vegetarian detection','keyword','vegetarian|veggie','vegetarian',90,1,'Explicitly vegetarian recipes','2025-05-31');
INSERT INTO tagging_rules VALUES(15,'Vegan detection','keyword','vegan','vegan',95,1,'Explicitly vegan recipes','2025-05-31');
INSERT INTO tagging_rules VALUES(16,'Gluten free detection','keyword','gluten.free|gf','gluten_free',90,1,'Explicitly gluten-free recipes','2025-05-31');
INSERT INTO tagging_rules VALUES(17,'Keto detection','keyword','keto|ketogenic|low.carb','keto',90,1,'Keto-friendly recipes','2025-05-31');
INSERT INTO tagging_rules VALUES(18,'Healthy detection','keyword','healthy|light|fresh','healthy',80,1,'Health-focused recipes','2025-05-31');
INSERT INTO tagging_rules VALUES(19,'Easy detection','keyword','easy|simple|quick','easy',85,1,'Simple recipes','2025-05-31');
INSERT INTO tagging_rules VALUES(20,'Comfort food detection','keyword','comfort|cozy|hearty','comfort_food',80,1,'Comfort food vibes','2025-05-31');
INSERT INTO tagging_rules VALUES(21,'Elegant detection','keyword','elegant|fancy|gourmet|restaurant','elegant',80,1,'Sophisticated dishes','2025-05-31');
INSERT INTO tagging_rules VALUES(22,'Summer detection','keyword','summer|cold|fresh|salad|gazpacho|no.cook','summer',75,1,'Summer-appropriate dishes','2025-05-31');
INSERT INTO tagging_rules VALUES(23,'Winter detection','keyword','winter|warm|soup|stew|comfort|braised','winter',75,1,'Winter comfort foods','2025-05-31');
INSERT INTO tagging_rules VALUES(24,'Holiday detection','keyword','holiday|christmas|thanksgiving|easter|celebration','holiday',85,1,'Holiday recipes','2025-05-31');
INSERT INTO tagging_rules VALUES(25,'Pork detection','name','pork','pork',95,1,'Recipe name contains pork','2025-05-31');
INSERT INTO tagging_rules VALUES(26,'Chicken detection','name','chicken','chicken',95,1,'Recipe name contains chicken','2025-05-31');
INSERT INTO tagging_rules VALUES(27,'Beef detection','name','beef|steak','beef',95,1,'Recipe name contains beef','2025-05-31');
INSERT INTO tagging_rules VALUES(28,'Balsamic detection','name','balsamic','balsamic',90,1,'Recipe name contains balsamic','2025-05-31');
INSERT INTO tagging_rules VALUES(29,'Tenderloin detection','name','tenderloin','tenderloin',90,1,'Recipe name contains tenderloin','2025-05-31');
INSERT INTO tagging_rules VALUES(30,'Garlic detection','name','garlic','garlic',85,1,'Recipe name contains garlic','2025-05-31');
INSERT INTO tagging_rules VALUES(31,'Mustard detection','name','mustard|dijon','mustard',85,1,'Recipe name contains mustard','2025-05-31');
INSERT INTO tagging_rules VALUES(32,'Pork detection','keyword','pork','pork',95,1,'Recipe name contains pork','2025-05-31');
INSERT INTO tagging_rules VALUES(33,'Balsamic detection','keyword','balsamic','balsamic',90,1,'Recipe name contains balsamic','2025-05-31');
INSERT INTO tagging_rules VALUES(34,'Tenderloin detection','keyword','tenderloin','tenderloin',90,1,'Recipe name contains tenderloin','2025-05-31');
CREATE TABLE people (
    person_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    nickname TEXT,
    role TEXT, -- 'primary_cook', 'household_member', 'frequent_guest'
    cooking_skill_level TEXT CHECK(cooking_skill_level IN ('Beginner', 'Intermediate', 'Advanced', 'Professional')),
    preferred_spice_level TEXT CHECK(preferred_spice_level IN ('Mild', 'Medium', 'Hot', 'Very Hot')),
    dietary_philosophy TEXT, -- 'omnivore', 'vegetarian', 'flexitarian', etc.
    notes TEXT,
    active BOOLEAN DEFAULT TRUE,
    date_added DATE DEFAULT (date('now'))
);
INSERT INTO people VALUES(1,'Brian','Brian','primary_cook','Advanced','Medium','omnivore','Advanced cook, healthy diet focus, works away from home for lunch/snacks',1,'2025-05-31');
INSERT INTO people VALUES(2,'Lilibeth','Lili','household_member','Advanced','Mild','omnivore','Advanced cook, loves eggplant and bananas, stays home for lunch/snacks',1,'2025-05-31');
CREATE TABLE allergies (
    allergy_id INTEGER PRIMARY KEY AUTOINCREMENT,
    allergy_name TEXT UNIQUE NOT NULL,
    severity TEXT CHECK(severity IN ('Mild', 'Moderate', 'Severe', 'Life-threatening')),
    category TEXT, -- 'food_allergy', 'intolerance', 'preference', 'religious'
    description TEXT
);
INSERT INTO allergies VALUES(1,'Hummus','Moderate','food_allergy','Allergic reaction to hummus');
INSERT INTO allergies VALUES(2,'Grapefruit','Moderate','food_allergy','Allergic reaction to grapefruit');
INSERT INTO allergies VALUES(3,'Wine_and_Beer','Moderate','food_allergy','Allergic reaction to wine and beer');
INSERT INTO allergies VALUES(4,'Raw_Carrots','Mild','food_allergy','Allergic reaction to raw carrots only');
INSERT INTO allergies VALUES(5,'Very_Spicy_Food','Moderate','intolerance','Cannot tolerate very spicy/hot food');
CREATE TABLE person_allergies (
    person_id INTEGER,
    allergy_id INTEGER,
    severity_override TEXT, -- can override the default severity for this person
    notes TEXT,
    date_diagnosed DATE,
    PRIMARY KEY (person_id, allergy_id),
    FOREIGN KEY (person_id) REFERENCES people(person_id) ON DELETE CASCADE,
    FOREIGN KEY (allergy_id) REFERENCES allergies(allergy_id)
);
INSERT INTO person_allergies VALUES(1,1,NULL,'Complete avoidance required',NULL);
INSERT INTO person_allergies VALUES(1,2,NULL,'Complete avoidance required',NULL);
INSERT INTO person_allergies VALUES(1,3,NULL,'All alcoholic beverages problematic',NULL);
INSERT INTO person_allergies VALUES(1,4,NULL,'Only raw carrots, cooked carrots are fine',NULL);
INSERT INTO person_allergies VALUES(2,5,NULL,'Cannot handle spicy heat level',NULL);
CREATE TABLE food_preferences (
    preference_id INTEGER PRIMARY KEY AUTOINCREMENT,
    person_id INTEGER NOT NULL,
    food_item TEXT NOT NULL, -- ingredient, cuisine, dish type, etc.
    preference_type TEXT CHECK(preference_type IN ('love', 'like', 'neutral', 'dislike', 'hate')),
    category TEXT, -- 'ingredient', 'cuisine', 'cooking_method', 'dish_type', 'flavor_profile'
    intensity INTEGER CHECK(intensity >= 1 AND intensity <= 5), -- how strong is this preference
    notes TEXT,
    date_added DATE DEFAULT (date('now')),
    FOREIGN KEY (person_id) REFERENCES people(person_id) ON DELETE CASCADE
);
INSERT INTO food_preferences VALUES(1,1,'eggplant','dislike','ingredient',4,'Dislikes eggplant while Lilibeth loves it','2025-05-31');
INSERT INTO food_preferences VALUES(2,1,'processed foods','dislike','food_type',5,'Strongly dislikes processed foods','2025-05-31');
INSERT INTO food_preferences VALUES(3,1,'meat','love','protein',5,'Loves all kinds of meat','2025-05-31');
INSERT INTO food_preferences VALUES(4,2,'eggplant','love','ingredient',5,'Loves eggplant while Brian dislikes it','2025-05-31');
INSERT INTO food_preferences VALUES(5,2,'bananas','love','ingredient',5,'Loves bananas','2025-05-31');
INSERT INTO food_preferences VALUES(6,2,'meat','love','protein',5,'Loves all kinds of meat','2025-05-31');
CREATE TABLE kitchen_equipment (
    equipment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    equipment_name TEXT UNIQUE NOT NULL,
    category TEXT, -- 'appliance', 'cookware', 'utensil', 'gadget'
    brand TEXT,
    model TEXT,
    size_capacity TEXT, -- '6-quart', '12-inch', etc.
    condition TEXT CHECK(condition IN ('Excellent', 'Good', 'Fair', 'Needs_Replacement')),
    purchase_date DATE,
    notes TEXT,
    active BOOLEAN DEFAULT TRUE
);
INSERT INTO kitchen_equipment VALUES(1,'Slow Cooker','appliance',NULL,NULL,NULL,'Good',NULL,'Available for meal prep',1);
INSERT INTO kitchen_equipment VALUES(2,'Air Fryer','appliance',NULL,NULL,NULL,'Good',NULL,'Great for healthy cooking',1);
INSERT INTO kitchen_equipment VALUES(3,'Blender','appliance',NULL,NULL,NULL,'Good',NULL,'For smoothies and sauces',1);
INSERT INTO kitchen_equipment VALUES(4,'Sous Vide','appliance',NULL,NULL,NULL,'Good',NULL,'Precision cooking equipment',1);
INSERT INTO kitchen_equipment VALUES(5,'Work Microwave','appliance',NULL,NULL,NULL,'Good',NULL,'Available at workplace',1);
CREATE TABLE pantry_items (
    item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    ingredient_id INTEGER, -- Links to existing ingredients table
    ingredient_name TEXT NOT NULL, -- For items not in ingredients table yet
    barcode TEXT,
    quantity REAL,
    unit TEXT,
    pieces INTEGER DEFAULT 1,
    level TEXT CHECK(level IN ('full', 'half', 'quarter', 'empty', 'unknown')),
    location TEXT CHECK(location IN ('pantry', 'fridge', 'freezer', 'spices', 'beverages', 'other')),
    expiry_date DATE,
    purchase_date DATE DEFAULT (date('now')),
    cost REAL,
    brand TEXT,
    notes TEXT,
    last_updated DATE DEFAULT (date('now')),
    source TEXT DEFAULT 'kitchenpal_import',
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
);
INSERT INTO pantry_items VALUES(11,NULL,'Albacore Tuna In Water','48000000958',5.0,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(12,NULL,'Vienna Sausage','39000086639',130.0,'g',1,'full','pantry','2025-11-21','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(13,NULL,'Dongwon Salted Cabbage Kimchi 5.7 Oz','883298182906',160.0,'g',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(14,NULL,'Bamboo Shoots','11152453040',8.0,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(15,NULL,'Whole Water Chestnuts','11152455297',8.0,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(16,NULL,'Dijon mustard','41500000992',12.0,'oz',1,'full','fridge','2025-07-24','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(17,NULL,'Lemon Pepper','842798103590',1.0,'units',1,'half','pantry','2025-06-08','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(18,NULL,'White Kidney Bean','39400018704',15.0,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(19,NULL,'Chicken Bouillon Cubes','48001701014',7.5,'oz',3,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(20,NULL,'Black Peppercorns','78742252483',164.0,'g',1,'half','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(21,NULL,'Organic Ground Turmeric','33844002503',2.0,'oz',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(22,NULL,'Mama Sita''s Sinigang Mix','25407803108',200.0,'g',4,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(23,NULL,'Taco Seasoning Mix','46000288697',4.0,'oz',4,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(24,NULL,'Bay Leaves Whole','33844000196',11.33999999999999986,'oz',2,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(25,NULL,'Soy sauce','44300125131',10.0,'oz',1,'half','fridge',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(26,NULL,'Seed Chia','33844000455',1.0,'units',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(27,NULL,'Garlic Salt','78742254647',5.700000000000000177,'oz',1,'half','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(28,NULL,'Parsley flakes','41512143700',1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(29,NULL,'Crispy fry spicy','4801958391105',500.0,'ml',2,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(30,NULL,'Datu Puti Vinegar','737964000257',1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(31,NULL,'Pompeian Organic Smooth Extra Virgin Olive Oil, 32 Fl Oz','70404008209',1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(32,NULL,'red wine vinegar','70404001002',16.0,'oz',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(33,NULL,'Worcestershire Sauce','5160337',5.0,'oz',1,'half','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(34,NULL,'Power Up Trail Mix, Protein','857468006170',1.0,'units',1,'full','other',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - other','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(35,NULL,'Uncle Ben''s Long Grain & Wild Rice',NULL,6.0,'oz',1,'full','pantry','2027-05-25','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(36,NULL,'Jasmine Rice','8850006321034',5.0,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(37,NULL,'Chocolate Hazelnut Spread','40000521242',26.5,'oz',1,'full','pantry','2025-06-04','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(38,NULL,'Nescafe Gold','7613037001242',7.049999999999999823,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(39,NULL,'Oil','8801173213213',16.89999999999999857,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(40,NULL,'coconut milk','16229011383',13.5,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(41,NULL,'Honey','722252101310',24.0,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(42,NULL,'Black Sesame seeds','8852778004868',7.0,'oz',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(43,NULL,'Tomato Paste','41130044014',6.0,'oz',3,'full','pantry','2026-05-02','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(44,NULL,'Red Hot Sauce','11199058008',5.0,'oz',1,'full','fridge','2025-08-29','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(45,NULL,'Dried Shiitake Mushrooms','8859168500026',3.5,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(46,NULL,'Baking Soda','33200001072',16.0,'oz',2,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(47,NULL,'Sesame Oil','11152202108',6.200000000000000177,'oz',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(48,NULL,'Lee Kum Kee Hoisin Sauce 8oz','78895330502',8.0,'oz',1,'full','fridge','2025-08-17','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(49,NULL,'Banana Chips','8850157472012',3.5,'oz',1,'full','other',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - other','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(50,NULL,'Oyster flavored Sauce','78895330328',9.0,'oz',1,'full','fridge','2025-08-27','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(51,NULL,'Brown Rice','78895330472',2.0,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(52,NULL,'coconut milk','7622210951298',400.0,'g',1,'full','pantry','2026-04-12','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(53,NULL,'Tomato Ketchup','57000006187',32.0,'oz',1,'full','fridge','2026-02-07','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(54,NULL,'Tamarind Concentrate','8855273025005',454.0,'g',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(55,NULL,'Crushed Red Pepper','33844003227',1.5,'oz',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(56,NULL,'Organic Chili Powder','33844002862',3.0,'oz',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(57,NULL,'Organic Garlic Powder','33844000592',2.330000000000000071,'oz',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(58,NULL,'Pam Organic Olive Oil Cooking spray 5oz','64100070004',5.0,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(59,NULL,'Whole Wheat Pasta Fusilli','41262282476',13.25,'oz',1,'full','pantry','2026-05-03','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(60,NULL,'Crushed Tomatoes','41130044021',28.0,'oz',1,'full','pantry','2025-10-09','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(61,NULL,'Organic Tomato Sauce','41262243736',15.0,'oz',2,'full','pantry','2026-05-23','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(62,NULL,'Diced Tomatoes','41130044113',14.5,'oz',1,'full','pantry','2026-03-25','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(63,NULL,'Regular Cheerios','16000275270',20.35000000000000143,'oz',1,'full','pantry','2025-07-02','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(64,NULL,'Prune Juice','16000136410',32.0,'oz',1,'full','fridge','2025-08-02','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(65,NULL,'Asian Pears',NULL,1.0,'units',1,'full','fridge','2025-06-12','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(66,NULL,'Red Bell Pepper',NULL,1.0,'units',1,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(67,NULL,'Green Bell Pepper',NULL,1.0,'units',1,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(68,NULL,'Yellow Bell Pepper',NULL,1.0,'units',1,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(69,NULL,'Orange Bell Pepper',NULL,1.0,'units',1,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(70,NULL,'Limes',NULL,1.0,'units',6,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(71,NULL,'Lemons',NULL,1.0,'units',3,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(72,NULL,'White Onions',NULL,1.0,'units',3,'full','pantry','2025-06-22','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(73,NULL,'Yellow Onions',NULL,1.0,'units',3,'full','pantry','2025-06-22','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(74,NULL,'Red Onions',NULL,1.0,'units',2,'full','pantry','2025-06-22','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(75,NULL,'Sweet Onions',NULL,1.0,'units',2,'full','pantry','2025-06-22','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(76,NULL,'Garlic',NULL,1.0,'units',2,'full','pantry','2025-06-29','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(77,NULL,'Green Onions',NULL,1.0,'units',1,'full','fridge','2025-06-08','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(78,NULL,'Ginger',NULL,1.0,'units',1,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(79,NULL,'Cilantro',NULL,1.0,'units',1,'full','fridge','2025-06-08','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(80,NULL,'Thai Basil',NULL,1.0,'units',1,'full','fridge','2025-06-08','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(81,NULL,'Carrots',NULL,1.0,'units',1,'full','fridge','2025-06-22','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(82,NULL,'Celery',NULL,1.0,'units',1,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(83,NULL,'Tomatoes',NULL,1.0,'units',4,'full','fridge','2025-06-08','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(84,NULL,'Cherry Tomatoes',NULL,1.0,'units',1,'full','fridge','2025-06-08','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(85,NULL,'Cucumber',NULL,1.0,'units',2,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(86,NULL,'Zucchini',NULL,1.0,'units',2,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(87,NULL,'Mushrooms',NULL,1.0,'units',1,'full','fridge','2025-06-10','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(88,NULL,'Potatoes',NULL,1.0,'units',5,'full','pantry','2025-07-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(89,NULL,'Sweet Potatoes',NULL,1.0,'units',3,'full','pantry','2025-07-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(90,NULL,'Russet Potatoes',NULL,1.0,'units',5,'full','pantry','2025-07-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(91,NULL,'Red Potatoes',NULL,1.0,'units',3,'full','pantry','2025-07-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(92,NULL,'Bananas',NULL,1.0,'units',6,'full','other','2025-06-08','2025-06-02',NULL,NULL,'Complete KitchenPal import - other','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(93,NULL,'Apples',NULL,1.0,'units',4,'full','fridge','2025-06-22','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(94,NULL,'Oranges',NULL,1.0,'units',4,'full','other','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - other','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(95,NULL,'Green Beans',NULL,1.0,'units',1,'full','fridge','2025-06-10','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(96,NULL,'Broccoli',NULL,1.0,'units',1,'full','fridge','2025-06-10','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(97,NULL,'Cauliflower',NULL,1.0,'units',1,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(98,NULL,'Spinach',NULL,1.0,'units',1,'full','fridge','2025-06-08','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(99,NULL,'Lettuce',NULL,1.0,'units',1,'full','fridge','2025-06-10','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(100,NULL,'Cabbage',NULL,1.0,'units',1,'full','fridge','2025-06-22','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(101,NULL,'Bok Choy',NULL,1.0,'units',1,'full','fridge','2025-06-10','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(102,NULL,'Asparagus',NULL,1.0,'units',1,'full','fridge','2025-06-08','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(103,NULL,'Brussels Sprouts',NULL,1.0,'units',1,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(104,NULL,'Eggplant',NULL,1.0,'units',1,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(105,NULL,'Corn',NULL,1.0,'units',2,'full','fridge','2025-06-12','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(106,NULL,'Avocados',NULL,1.0,'units',3,'full','other','2025-06-08','2025-06-02',NULL,NULL,'Complete KitchenPal import - other','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(107,NULL,'Ground Beef',NULL,1.0,'units',1,'full','freezer','2025-09-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - freezer','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(108,NULL,'Ground Turkey',NULL,1.0,'units',1,'full','freezer','2025-09-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - freezer','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(109,NULL,'Chicken Breast',NULL,1.0,'units',2,'full','freezer','2025-09-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - freezer','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(110,NULL,'Chicken Thighs',NULL,1.0,'units',1,'full','freezer','2025-09-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - freezer','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(111,NULL,'Pork Chops',NULL,1.0,'units',4,'full','freezer','2025-09-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - freezer','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(112,NULL,'Salmon Fillets',NULL,1.0,'units',2,'full','freezer','2025-09-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - freezer','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(113,NULL,'Shrimp',NULL,1.0,'units',1,'full','freezer','2025-09-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - freezer','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(114,NULL,'Bacon',NULL,1.0,'units',1,'full','fridge','2025-07-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(115,NULL,'Italian Sausage',NULL,1.0,'units',1,'full','freezer','2025-09-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - freezer','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(116,NULL,'Eggs',NULL,1.0,'units',12,'full','fridge','2025-06-20','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(117,NULL,'Milk',NULL,1.0,'units',1,'full','fridge','2025-06-12','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(118,NULL,'Heavy Cream',NULL,1.0,'units',1,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(119,NULL,'Butter',NULL,1.0,'units',1,'full','fridge','2025-07-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(120,NULL,'Cheese - Cheddar',NULL,1.0,'units',1,'full','fridge','2025-07-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(121,NULL,'Cheese - Mozzarella',NULL,1.0,'units',1,'full','fridge','2025-07-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(122,NULL,'Cheese - Parmesan',NULL,1.0,'units',1,'full','fridge','2025-08-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(123,NULL,'Greek Yogurt',NULL,1.0,'units',1,'full','fridge','2025-06-15','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(124,NULL,'Cream Cheese',NULL,1.0,'units',1,'full','fridge','2025-07-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - fridge','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(125,NULL,'Bread - White',NULL,1.0,'units',1,'full','pantry','2025-06-08','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(126,NULL,'Bread - Whole Wheat',NULL,1.0,'units',1,'full','pantry','2025-06-08','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(127,NULL,'Flour - All Purpose',NULL,5.0,'oz',1,'full','pantry','2026-06-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(128,NULL,'Sugar - White',NULL,4.0,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(129,NULL,'Sugar - Brown',NULL,2.0,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(130,NULL,'Vanilla Extract',NULL,1.0,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(131,NULL,'Baking Powder',NULL,1.0,'units',1,'full','pantry','2026-03-01','2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(132,NULL,'Salt',NULL,26.0,'oz',1,'full','pantry',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - pantry','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(133,NULL,'Black Pepper',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(134,NULL,'Paprika',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(135,NULL,'Cumin',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(136,NULL,'Oregano',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(137,NULL,'Thyme',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(138,NULL,'Rosemary',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(139,NULL,'Basil',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(140,NULL,'Cinnamon',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(141,NULL,'Nutmeg',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(142,NULL,'Garam Masala',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(143,NULL,'Curry Powder',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(144,NULL,'Chinese Five Spice',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(145,NULL,'Italian Seasoning',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(146,NULL,'Onion Powder',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(147,NULL,'Cayenne Pepper',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
INSERT INTO pantry_items VALUES(148,NULL,'Smoked Paprika',NULL,1.0,'units',1,'full','spices',NULL,'2025-06-02',NULL,NULL,'Complete KitchenPal import - spices','2025-06-02','kitchenpal_import');
CREATE TABLE master_ingredients (
    master_id INTEGER PRIMARY KEY AUTOINCREMENT,
    ingredient_key TEXT UNIQUE NOT NULL, -- unique identifier like 'black_pepper', 'pork_tenderloin'
    display_name TEXT NOT NULL, -- What shows in recipes: 'Black Pepper', 'Pork Tenderloin'
    category TEXT, -- 'protein', 'spice', 'vegetable', 'oil', 'condiment'
    subcategory TEXT, -- 'pork_cuts', 'ground_spices', 'whole_spices', etc.
    description TEXT, -- 'Freshly ground black peppercorns', 'Lean cut from pork loin'
    common_units TEXT, -- 'tsp, tbsp, oz', 'lb, oz, pieces'
    storage_location TEXT, -- 'spices', 'freezer', 'pantry', 'fridge'
    notes TEXT,
    date_created DATE DEFAULT (date('now')),
    active BOOLEAN DEFAULT TRUE
);
INSERT INTO master_ingredients VALUES(1,'pork_tenderloin','Pork Tenderloin','protein','pork_cuts','Lean, tender cut from pork loin','lb, oz','freezer',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(2,'pork_chops','Pork Chops','protein','pork_cuts','Bone-in or boneless chops','pieces, lb','freezer',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(3,'ground_pork','Ground Pork','protein','pork_ground','Ground pork for sausages, meatballs','lb, oz','freezer',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(4,'black_pepper_ground','Black Pepper (Ground)','spice','ground_spices','Pre-ground black pepper','tsp, tbsp, oz','spices',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(5,'black_peppercorns_whole','Black Peppercorns (Whole)','spice','whole_spices','Whole black peppercorns for grinding','tsp, tbsp, oz','spices',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(6,'white_pepper_ground','White Pepper (Ground)','spice','ground_spices','Milder than black pepper','tsp, tbsp, oz','spices',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(7,'garlic_fresh','Garlic (Fresh)','vegetable','aromatics','Fresh garlic cloves','cloves, bulbs','pantry',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(8,'garlic_powder','Garlic Powder','spice','ground_spices','Dehydrated ground garlic','tsp, tbsp, oz','spices',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(9,'garlic_salt','Garlic Salt','seasoning','seasoning_blends','Salt mixed with garlic powder','tsp, tbsp, oz','spices',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(10,'balsamic_vinegar','Balsamic Vinegar','condiment','vinegars','Traditional Italian balsamic vinegar','tbsp, cups, oz','pantry',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(11,'red_wine_vinegar','Red Wine Vinegar','condiment','vinegars','Vinegar made from red wine','tbsp, cups, oz','pantry',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(12,'white_vinegar','White Vinegar','condiment','vinegars','Distilled white vinegar','tbsp, cups, oz','pantry',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(14,'olive_oil','Olive Oil','oil','cooking_oils','Refined olive oil for cooking','tbsp, cups, oz','pantry',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(15,'dijon_mustard','Dijon Mustard','condiment','mustards','French-style mustard','tsp, tbsp, oz','fridge',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(16,'yellow_mustard','Yellow Mustard','condiment','mustards','American-style yellow mustard','tsp, tbsp, oz','fridge',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(18,'table_salt','Table Salt','seasoning','basic_seasonings','Table Salt','tsp, tbsp, oz','pantry',NULL,'2025-06-02',1);
INSERT INTO master_ingredients VALUES(19,'lemon_pepper','Lemon Pepper Seasoning','spice','seasoning_blends','Lemon pepper seasoning blend','tsp, tbsp, oz','spices',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(20,'crushed_red_pepper','Crushed Red Pepper','spice','hot_spices','Dried crushed red pepper flakes','tsp, tbsp, oz','spices',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(21,'sesame_oil','Sesame Oil','oil','specialty_oils','Asian sesame oil for flavoring','tsp, tbsp, oz','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(22,'bell_pepper_red','Red Bell Pepper','vegetable','peppers','Fresh red bell peppers','pieces, cups','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(23,'bell_pepper_green','Green Bell Pepper','vegetable','peppers','Fresh green bell peppers','pieces, cups','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(24,'bell_pepper_yellow','Yellow Bell Pepper','vegetable','peppers','Fresh yellow bell peppers','pieces, cups','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(25,'bell_pepper_orange','Orange Bell Pepper','vegetable','peppers','Fresh orange bell peppers','pieces, cups','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(26,'kimchi','Kimchi','condiment','fermented','Korean fermented cabbage','cups, oz','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(35,'apples','Apples','fruit','fresh_fruit','Fresh apples','pieces, cups','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(36,'avocados','Avocados','fruit','fresh_fruit','Fresh avocados','pieces, cups','other',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(37,'bananas','Bananas','fruit','fresh_fruit','Fresh bananas','pieces, cups','other',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(38,'lemons','Lemons','fruit','citrus','Fresh lemons','pieces, juice','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(39,'limes','Limes','fruit','citrus','Fresh limes','pieces, juice','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(40,'broccoli','Broccoli','vegetable','cruciferous','Fresh broccoli','cups, heads','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(41,'carrots','Carrots','vegetable','root_vegetables','Fresh carrots','pieces, cups','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(42,'celery','Celery','vegetable','stalks','Fresh celery','stalks, cups','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(43,'mushrooms','Mushrooms','vegetable','fungi','Fresh mushrooms','cups, pieces','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(44,'spinach','Spinach','vegetable','leafy_greens','Fresh spinach','cups, oz','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(45,'potatoes','Potatoes','vegetable','root_vegetables','Fresh potatoes','pieces, lbs','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(46,'corn','Corn','vegetable','grains','Fresh or frozen corn','cups, ears','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(47,'cabbage','Cabbage','vegetable','cruciferous','Fresh cabbage','heads, cups','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(48,'green_beans','Green Beans','vegetable','legumes','Fresh green beans','cups, lbs','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(49,'white_kidney_beans','White Kidney Beans','protein','legumes','Canned or dried white kidney beans','cups, cans','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(50,'beans','Beans (Generic)','protein','legumes','Generic beans','cups, cans','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(51,'basil','Basil','herb','fresh_herbs','Fresh basil','leaves, cups','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(52,'thai_basil','Thai Basil','herb','fresh_herbs','Fresh Thai basil','leaves, cups','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(53,'cilantro','Cilantro','herb','fresh_herbs','Fresh cilantro','cups, bunches','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(54,'ginger','Ginger','spice','fresh_spices','Fresh ginger root','pieces, tbsp','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(55,'butter','Butter','dairy','fats','Butter','tbsp, sticks','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(56,'eggs','Eggs','protein','poultry','Chicken eggs','pieces, dozen','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(57,'milk','Milk','dairy','liquids','Milk','cups, oz','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(58,'heavy_cream','Heavy Cream','dairy','cream','Heavy whipping cream','cups, oz','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(59,'cream_cheese','Cream Cheese','dairy','cheese','Cream cheese','oz, packages','fridge',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(60,'sugar_white','White Sugar','baking','sweeteners','White granulated sugar','cups, lbs','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(61,'sugar_brown','Brown Sugar','baking','sweeteners','Brown sugar','cups, lbs','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(62,'flour','All-Purpose Flour','baking','flours','All-purpose flour','cups, lbs','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(63,'baking_powder','Baking Powder','baking','leavening','Baking powder','tsp, cans','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(64,'vanilla_extract','Vanilla Extract','baking','extracts','Pure vanilla extract','tsp, bottles','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(65,'rice_brown','Brown Rice','grain','rice','Brown rice','cups, lbs','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(66,'rice_jasmine','Jasmine Rice','grain','rice','Jasmine rice','cups, lbs','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(67,'rice_wild','Wild Rice','grain','rice','Wild rice blend','cups, lbs','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(68,'bread_white','White Bread','grain','bread','White bread','slices, loaves','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(69,'bread_whole_wheat','Whole Wheat Bread','grain','bread','Whole wheat bread','slices, loaves','pantry',NULL,'2025-06-03',1);
INSERT INTO master_ingredients VALUES(70,'tomatoes_fresh','Tomatoes (Fresh)','vegetable','nightshades','Fresh tomatoes for cooking and salads','pieces, lbs, cups','fridge','Includes cherry tomatoes and regular tomatoes','2025-06-04',1);
INSERT INTO master_ingredients VALUES(71,'tomatoes_canned','Tomatoes (Canned)','vegetable','canned_vegetables','Canned tomato products for cooking','cans, cups, oz','pantry','Includes diced, crushed, sauce, and paste','2025-06-04',1);
INSERT INTO master_ingredients VALUES(72,'cherry_tomatoes','Cherry Tomatoes','vegetable','nightshades','Small fresh tomatoes','cups, pints, pieces','fridge','Specific variety of fresh tomatoes','2025-06-04',1);
INSERT INTO master_ingredients VALUES(73,'onions_yellow','Yellow Onions','vegetable','aromatics','Standard cooking onions','pieces, lbs, cups','pantry','Most common onion variety - includes sweet onions','2025-06-04',1);
INSERT INTO master_ingredients VALUES(74,'onions_red','Red Onions','vegetable','aromatics','Red/purple onions for salads and cooking','pieces, lbs, cups','pantry','Good raw or cooked','2025-06-04',1);
INSERT INTO master_ingredients VALUES(75,'onions_white','White Onions','vegetable','aromatics','White onions for cooking','pieces, lbs, cups','pantry','Milder than yellow onions','2025-06-04',1);
INSERT INTO master_ingredients VALUES(76,'green_onions','Green Onions','vegetable','aromatics','Scallions/spring onions','bunches, pieces, cups','fridge','Also called scallions or spring onions','2025-06-04',1);
INSERT INTO master_ingredients VALUES(77,'cheese_parmesan','Parmesan Cheese','dairy','hard_cheese','Aged Italian hard cheese','cups, oz, pieces','fridge','Grated or block form','2025-06-04',1);
INSERT INTO master_ingredients VALUES(78,'cheese_mozzarella','Mozzarella Cheese','dairy','soft_cheese','Italian cheese for melting','cups, oz, pieces','fridge','Fresh or low-moisture varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(79,'cheese_cheddar','Cheddar Cheese','dairy','hard_cheese','Sharp or mild cheddar cheese','cups, oz, pieces','fridge','Various ages and sharpness levels','2025-06-04',1);
INSERT INTO master_ingredients VALUES(80,'yogurt_greek','Greek Yogurt','dairy','yogurt','Thick strained yogurt','cups, containers, oz','fridge','Plain or flavored varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(81,'chicken_breast','Chicken Breast','protein','poultry','Boneless chicken breast meat','lbs, pieces, oz','freezer','Lean white meat cut','2025-06-04',1);
INSERT INTO master_ingredients VALUES(82,'chicken_thighs','Chicken Thighs','protein','poultry','Chicken thigh meat','lbs, pieces, oz','freezer','Dark meat - bone-in or boneless','2025-06-04',1);
INSERT INTO master_ingredients VALUES(83,'ground_beef','Ground Beef','protein','beef_ground','Ground beef for cooking','lbs, oz','freezer','Various fat percentages available','2025-06-04',1);
INSERT INTO master_ingredients VALUES(84,'ground_turkey','Ground Turkey','protein','poultry_ground','Ground turkey meat','lbs, oz','freezer','Lean alternative to ground beef','2025-06-04',1);
INSERT INTO master_ingredients VALUES(85,'eggplant','Eggplant','vegetable','nightshades','Purple eggplant for cooking','pieces, lbs, cups','fridge','Lilibeth loves, Brian dislikes','2025-06-04',1);
INSERT INTO master_ingredients VALUES(86,'paprika_regular','Paprika','spice','ground_spices','Ground paprika spice','tsp, tbsp, oz','spices','Includes regular and smoked varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(87,'onion_powder','Onion Powder','spice','ground_spices','Dehydrated ground onion','tsp, tbsp, oz','spices','Convenient onion flavoring','2025-06-04',1);
INSERT INTO master_ingredients VALUES(88,'oregano','Oregano','spice','herbs','Dried oregano herb','tsp, tbsp, oz','spices','Mediterranean herb for cooking','2025-06-04',1);
INSERT INTO master_ingredients VALUES(89,'brussels_sprouts','Brussels Sprouts','vegetable','cruciferous','Small cabbage-like vegetables','cups, lbs, pieces','fridge','Roast or sauté for best flavor','2025-06-04',1);
INSERT INTO master_ingredients VALUES(90,'asparagus','Asparagus','vegetable','stalks','Fresh asparagus spears','bunches, cups, pieces','fridge','Trim woody ends before cooking','2025-06-04',1);
INSERT INTO master_ingredients VALUES(91,'bok_choy','Bok Choy','vegetable','leafy_greens','Asian leafy green vegetable','heads, cups','fridge','Use both leaves and stalks','2025-06-04',1);
INSERT INTO master_ingredients VALUES(92,'lettuce','Lettuce','vegetable','leafy_greens','Fresh lettuce for salads','heads, cups, bags','fridge','Various types - romaine, iceberg, etc.','2025-06-04',1);
INSERT INTO master_ingredients VALUES(93,'cauliflower','Cauliflower','vegetable','cruciferous','White cruciferous vegetable','heads, cups, pieces','fridge','Can substitute for rice or potatoes','2025-06-04',1);
INSERT INTO master_ingredients VALUES(94,'zucchini','Zucchini','vegetable','squash','Summer squash vegetable','pieces, cups, lbs','fridge','Very versatile - grill, sauté, or bake','2025-06-04',1);
INSERT INTO master_ingredients VALUES(95,'cucumber','Cucumber','vegetable','fresh_vegetables','Fresh cucumber for salads','pieces, cups','fridge','Great for salads and snacking','2025-06-04',1);
INSERT INTO master_ingredients VALUES(96,'chili_powder','Chili Powder','spice','ground_spices','Ground chili spice blend','tsp, tbsp, oz','spices','Blend of chilies and spices','2025-06-04',1);
INSERT INTO master_ingredients VALUES(97,'cayenne_pepper','Cayenne Pepper','spice','hot_spices','Ground cayenne pepper','tsp, tbsp, oz','spices','Very hot - use sparingly','2025-06-04',1);
INSERT INTO master_ingredients VALUES(98,'turmeric','Turmeric','spice','ground_spices','Ground turmeric root','tsp, tbsp, oz','spices','Golden spice with earthy flavor','2025-06-04',1);
INSERT INTO master_ingredients VALUES(99,'cinnamon','Cinnamon','spice','sweet_spices','Ground cinnamon bark','tsp, tbsp, oz','spices','Sweet and warm spice','2025-06-04',1);
INSERT INTO master_ingredients VALUES(100,'nutmeg','Nutmeg','spice','sweet_spices','Ground nutmeg seed','tsp, tbsp, oz','spices','Warm, sweet, and slightly nutty','2025-06-04',1);
INSERT INTO master_ingredients VALUES(101,'thyme','Thyme','spice','herbs','Dried thyme leaves','tsp, tbsp, oz','spices','Earthy herb for Mediterranean cooking','2025-06-04',1);
INSERT INTO master_ingredients VALUES(102,'rosemary','Rosemary','spice','herbs','Dried rosemary leaves','tsp, tbsp, oz','spices','Pine-like flavor, great with potatoes','2025-06-04',1);
INSERT INTO master_ingredients VALUES(103,'cumin','Cumin','spice','ground_spices','Ground cumin seeds','tsp, tbsp, oz','spices','Warm, earthy flavor for Middle Eastern dishes','2025-06-04',1);
INSERT INTO master_ingredients VALUES(104,'bay_leaves','Bay Leaves','spice','whole_herbs','Dried bay leaves','pieces, oz','spices','Remove before serving','2025-06-04',1);
INSERT INTO master_ingredients VALUES(105,'parsley_dried','Parsley (Dried)','spice','herbs','Dried parsley flakes','tsp, tbsp, oz','spices','Mild herb for garnish and flavor','2025-06-04',1);
INSERT INTO master_ingredients VALUES(106,'bacon','Bacon','protein','pork_cured','Cured pork bacon strips','slices, lbs, packages','fridge','Cook until crispy','2025-06-04',1);
INSERT INTO master_ingredients VALUES(107,'shrimp','Shrimp','protein','seafood','Fresh or frozen shrimp','lbs, pieces, oz','freezer','Various sizes available','2025-06-04',1);
INSERT INTO master_ingredients VALUES(108,'salmon_fillets','Salmon Fillets','protein','seafood','Fresh salmon fish fillets','fillets, lbs, oz','freezer','Rich in omega-3 fatty acids','2025-06-04',1);
INSERT INTO master_ingredients VALUES(109,'italian_sausage','Italian Sausage','protein','pork_sausage','Seasoned Italian pork sausage','links, lbs, packages','freezer','Sweet or hot varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(110,'soy_sauce','Soy Sauce','condiment','asian_sauces','Fermented soy sauce','tbsp, cups, bottles','pantry','Essential for Asian cooking','2025-06-04',1);
INSERT INTO master_ingredients VALUES(111,'hoisin_sauce','Hoisin Sauce','condiment','asian_sauces','Sweet Chinese sauce','tbsp, cups, jars','fridge','Sweet and savory flavor','2025-06-04',1);
INSERT INTO master_ingredients VALUES(112,'oyster_sauce','Oyster Sauce','condiment','asian_sauces','Thick savory sauce','tbsp, cups, bottles','fridge','Rich umami flavor','2025-06-04',1);
INSERT INTO master_ingredients VALUES(113,'honey','Honey','sweetener','natural_sweeteners','Pure honey','tbsp, cups, jars','pantry','Natural sweetener and flavor enhancer','2025-06-04',1);
INSERT INTO master_ingredients VALUES(114,'baking_soda','Baking Soda','baking','leavening','Sodium bicarbonate for baking','tsp, tbsp, boxes','pantry','Leavening agent and cleaning helper','2025-06-04',1);
INSERT INTO master_ingredients VALUES(115,'sesame_seeds','Sesame Seeds','seeds','cooking_seeds','Black or white sesame seeds','tsp, tbsp, cups','pantry','Nutty flavor for Asian dishes','2025-06-04',1);
INSERT INTO master_ingredients VALUES(116,'italian_seasoning','Italian Seasoning','spice','seasoning_blends','Blend of Italian herbs','tsp, tbsp, oz','spices','Oregano, basil, thyme blend','2025-06-04',1);
INSERT INTO master_ingredients VALUES(117,'taco_seasoning','Taco Seasoning Mix','spice','seasoning_blends','Mexican spice blend for tacos','packets, tsp, tbsp','spices','Pre-mixed taco spices','2025-06-04',1);
INSERT INTO master_ingredients VALUES(118,'chinese_five_spice','Chinese Five Spice','spice','seasoning_blends','Traditional Chinese spice blend','tsp, tbsp, oz','spices','Sweet and savory Asian blend','2025-06-04',1);
INSERT INTO master_ingredients VALUES(119,'curry_powder','Curry Powder','spice','seasoning_blends','Indian curry spice blend','tsp, tbsp, oz','spices','Turmeric-based spice mix','2025-06-04',1);
INSERT INTO master_ingredients VALUES(120,'garam_masala','Garam Masala','spice','seasoning_blends','Warm Indian spice blend','tsp, tbsp, oz','spices','Warming spices for Indian dishes','2025-06-04',1);
INSERT INTO master_ingredients VALUES(121,'ketchup','Tomato Ketchup','condiment','tomato_based','Tomato ketchup condiment','tbsp, cups, bottles','pantry','Classic tomato condiment','2025-06-04',1);
INSERT INTO master_ingredients VALUES(122,'hot_sauce','Hot Sauce','condiment','spicy_sauces','Spicy pepper sauce','tsp, tbsp, bottles','fridge','Add heat to any dish','2025-06-04',1);
INSERT INTO master_ingredients VALUES(123,'worcestershire_sauce','Worcestershire Sauce','condiment','fermented_sauces','Fermented savory sauce','tsp, tbsp, bottles','pantry','Complex umami flavor','2025-06-04',1);
INSERT INTO master_ingredients VALUES(124,'vinegar_asian','Asian Vinegar','condiment','vinegars','Asian-style vinegar','tbsp, cups, bottles','pantry','For Asian cooking and dressings','2025-06-04',1);
INSERT INTO master_ingredients VALUES(125,'bouillon_cubes','Bouillon Cubes','pantry','flavor_enhancers','Concentrated broth cubes','cubes, packets','pantry','Instant broth for cooking','2025-06-04',1);
INSERT INTO master_ingredients VALUES(126,'water_chestnuts','Water Chestnuts','vegetable','canned_vegetables','Canned water chestnuts','cans, cups','pantry','Crunchy texture for stir-fries','2025-06-04',1);
INSERT INTO master_ingredients VALUES(127,'bamboo_shoots','Bamboo Shoots','vegetable','canned_vegetables','Canned bamboo shoots','cans, cups','pantry','Asian vegetable for stir-fries','2025-06-04',1);
INSERT INTO master_ingredients VALUES(128,'vienna_sausage','Vienna Sausage','protein','canned_meat','Canned Vienna sausages','cans, pieces','pantry','Convenient canned protein','2025-06-04',1);
INSERT INTO master_ingredients VALUES(129,'chia_seeds','Chia Seeds','seeds','superfoods','Nutritious chia seeds','tbsp, cups, bags','pantry','High in omega-3 and fiber','2025-06-04',1);
INSERT INTO master_ingredients VALUES(130,'breakfast_cereal','Breakfast Cereal','grain','cereals','Ready-to-eat breakfast cereal','cups, boxes','pantry','Various types and brands','2025-06-04',1);
INSERT INTO master_ingredients VALUES(131,'chocolate_spread','Chocolate Hazelnut Spread','condiment','sweet_spreads','Chocolate and hazelnut spread','tbsp, jars','pantry','Sweet spread for bread and desserts','2025-06-04',1);
INSERT INTO master_ingredients VALUES(132,'pasta_alternative','Alternative Pasta','grain','specialty_pasta','Chickpea, lentil, and other alternative pastas','boxes, cups, oz','pantry','Banza and other protein-rich pastas','2025-06-04',1);
INSERT INTO master_ingredients VALUES(133,'instant_noodles','Instant Noodles','grain','quick_meals','Cup noodles and ramen varieties','cups, packages','pantry','Quick cooking noodle meals','2025-06-04',1);
INSERT INTO master_ingredients VALUES(134,'rice_flavored','Flavored Rice Mixes','grain','rice_varieties','Seasoned and flavored rice blends','boxes, cups','pantry','Pre-seasoned rice products','2025-06-04',1);
INSERT INTO master_ingredients VALUES(135,'rice_specialty','Specialty Rice','grain','rice_varieties','Long grain, wild, and mixed rice varieties','boxes, cups, lbs','pantry','Premium and mixed rice blends','2025-06-04',1);
INSERT INTO master_ingredients VALUES(136,'condensed_milk','Sweetened Condensed Milk','dairy','milk_products','Sweetened condensed milk for baking','cans, cups','pantry','Essential for desserts and baking','2025-06-04',1);
INSERT INTO master_ingredients VALUES(137,'cream_soup_base','Cream Soup Base','pantry','soup_mixes','Cream-based soup mixes and bases','packets, cans','pantry','Mushroom, chicken, and other cream soups','2025-06-04',1);
INSERT INTO master_ingredients VALUES(138,'chocolate_chips','Chocolate Chips','baking','chocolate','Baking chocolate chips and morsels','cups, bags, oz','pantry','Various chocolate types for baking','2025-06-04',1);
INSERT INTO master_ingredients VALUES(139,'dairy_alternatives','Dairy Alternatives','dairy','alternatives','Non-dairy milk and cream alternatives','containers, powder','pantry','Coconut, soy, and other alternatives','2025-06-04',1);
INSERT INTO master_ingredients VALUES(140,'peanut_butter','Peanut Butter','pantry','nut_butters','Peanut butter and nut spreads','jars, tbsp, cups','pantry','Creamy and crunchy varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(141,'cooking_spray','Cooking Spray','oil','specialty_oils','Non-stick cooking sprays','cans, sprays','pantry','Butter, olive oil, and plain varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(142,'specialty_oils','Specialty Cooking Oils','oil','cooking_oils','Flavored and specialty cooking oils','bottles, tbsp, cups','pantry','Infused and specialty varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(143,'coconut_products','Coconut Products','pantry','coconut','Coconut milk powder and coconut items','packages, cups','pantry','Milk powder, flakes, and other coconut products','2025-06-04',1);
INSERT INTO master_ingredients VALUES(144,'seeds_specialty','Specialty Seeds','seeds','cooking_seeds','Coriander, sesame, and other cooking seeds','tbsp, cups, oz','pantry','Whole seeds for cooking and garnish','2025-06-04',1);
INSERT INTO master_ingredients VALUES(145,'nuts_snack','Snack Nuts','snacks','nuts','Flavored and prepared nuts','bags, cups, oz','pantry','Garlic nuts, roasted varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(146,'miso_products','Miso Products','condiment','japanese','Miso soup and miso-based products','packets, paste','pantry','White miso, soup mixes','2025-06-04',1);
INSERT INTO master_ingredients VALUES(147,'filipino_specialty','Filipino Specialty Items','pantry','filipino','Filipino cooking ingredients and foods','packages, cans','pantry','Longanisa, calamansi, and Filipino brands','2025-06-04',1);
INSERT INTO master_ingredients VALUES(148,'asian_soup_mixes','Asian Soup Mixes','pantry','soup_mixes','Asian-style soup bases and mixes','packets, cubes','pantry','Egg flower, guava, and specialty Asian soups','2025-06-04',1);
INSERT INTO master_ingredients VALUES(149,'crackers_specialty','Specialty Crackers','snacks','crackers','Wheat thins and specialty crackers','boxes, pieces','pantry','Low sodium, whole grain varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(150,'breading_mixes','Breading Mixes','pantry','coating_mixes','Coating and breading mixes for frying','packages, cups','pantry','Crispy fry and chicken coating mixes','2025-06-04',1);
INSERT INTO master_ingredients VALUES(151,'yeast','Baking Yeast','baking','leavening','Active dry yeast for bread making','packets, jars','pantry','Active dry and instant yeast varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(152,'sugar_varieties','Sugar Varieties','baking','sweeteners','Dark brown, light brown, and specialty sugars','cups, lbs, bags','pantry','Various sugar types for baking','2025-06-04',1);
INSERT INTO master_ingredients VALUES(153,'canned_fish','Canned Fish','protein','canned_seafood','Tuna varieties and canned seafood','cans, oz','pantry','Herb & garlic, plain, and flavored varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(154,'processed_meats','Processed Meats','protein','processed','Roast beef, deli meats, and processed proteins','packages, slices','fridge','Ready-to-eat meat products','2025-06-04',1);
INSERT INTO master_ingredients VALUES(155,'pasta_chickpea','Chickpea Pasta','grain','specialty_pasta','Banza and other chickpea-based pastas','boxes, cups, oz','pantry','High-protein alternative pasta','2025-06-04',1);
INSERT INTO master_ingredients VALUES(156,'noodles_instant','Instant Noodles','grain','quick_meals','Cup noodles and ramen varieties','cups, packages','pantry','Quick cooking noodle meals','2025-06-04',1);
INSERT INTO master_ingredients VALUES(157,'rice_seasoned','Seasoned Rice Mixes','grain','rice_varieties','Flavored rice blends and mixes','boxes, cups','pantry','Pre-seasoned rice products','2025-06-04',1);
INSERT INTO master_ingredients VALUES(158,'rice_wild_blend','Wild Rice Blends','grain','rice_varieties','Long grain and wild rice mixtures','boxes, cups, lbs','pantry','Premium rice blends','2025-06-04',1);
INSERT INTO master_ingredients VALUES(159,'milk_condensed','Condensed Milk','dairy','milk_products','Sweetened condensed milk for baking','cans, cups','pantry','Essential for desserts','2025-06-04',1);
INSERT INTO master_ingredients VALUES(160,'soup_cream_base','Cream Soup Base','pantry','soup_mixes','Cream-based soup mixes','packets, cans','pantry','Mushroom and other cream soups','2025-06-04',1);
INSERT INTO master_ingredients VALUES(161,'chips_chocolate','Chocolate Chips','baking','chocolate','Baking chocolate varieties','cups, bags, oz','pantry','Multiple chocolate types','2025-06-04',1);
INSERT INTO master_ingredients VALUES(162,'butter_peanut','Peanut Butter','pantry','nut_butters','Peanut butter and nut spreads','jars, tbsp, cups','pantry','Creamy and crunchy varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(163,'spray_cooking','Cooking Spray','oil','specialty_oils','Non-stick cooking sprays','cans, sprays','pantry','Various flavored sprays','2025-06-04',1);
INSERT INTO master_ingredients VALUES(164,'products_coconut','Coconut Products','pantry','coconut','Coconut milk powder and products','packages, cups','pantry','Various coconut items','2025-06-04',1);
INSERT INTO master_ingredients VALUES(165,'seeds_cooking','Cooking Seeds','seeds','specialty_seeds','Coriander, sesame, and specialty seeds','tbsp, cups, oz','pantry','Whole seeds for cooking','2025-06-04',1);
INSERT INTO master_ingredients VALUES(166,'nuts_flavored','Flavored Nuts','snacks','nuts','Seasoned and prepared nuts','bags, cups, oz','pantry','Garlic and other flavored nuts','2025-06-04',1);
INSERT INTO master_ingredients VALUES(167,'miso_soup','Miso Soup Products','condiment','japanese','Miso soup mixes and paste','packets, containers','pantry','White miso and soup varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(168,'filipino_foods','Filipino Specialty Foods','pantry','filipino','Filipino cooking ingredients','packages, cans','pantry','Filipino specialty items','2025-06-04',1);
INSERT INTO master_ingredients VALUES(169,'soup_asian','Asian Soup Mixes','pantry','soup_mixes','Asian-style soup bases','packets, cubes','pantry','Specialty Asian soup mixes','2025-06-04',1);
INSERT INTO master_ingredients VALUES(170,'crackers_whole_grain','Whole Grain Crackers','snacks','crackers','Wheat thins and specialty crackers','boxes, pieces','pantry','Healthy cracker varieties','2025-06-04',1);
INSERT INTO master_ingredients VALUES(171,'mix_breading','Breading Mix','pantry','coating_mixes','Coating mixes for frying','packages, cups','pantry','Crispy fry coating mixes','2025-06-04',1);
INSERT INTO master_ingredients VALUES(172,'yeast_baking','Baking Yeast','baking','leavening','Active dry yeast for bread','packets, jars','pantry','Bread making yeast','2025-06-04',1);
INSERT INTO master_ingredients VALUES(173,'sugar_brown_varieties','Brown Sugar Varieties','baking','sweeteners','Dark and light brown sugars','cups, lbs, bags','pantry','Various brown sugar types','2025-06-04',1);
INSERT INTO master_ingredients VALUES(174,'tuna_flavored','Flavored Tuna','protein','canned_seafood','Seasoned tuna varieties','cans, oz','pantry','Herb & garlic and other flavored tuna','2025-06-04',1);
INSERT INTO master_ingredients VALUES(175,'meat_deli','Deli Meats','protein','processed','Sliced deli and processed meats','packages, slices','fridge','Ready-to-eat meats','2025-06-04',1);
CREATE TABLE pantry_mapping_approvals (
    approval_id INTEGER PRIMARY KEY AUTOINCREMENT,
    pantry_ingredient_name TEXT NOT NULL, -- Original name from KitchenPal
    suggested_master_key TEXT, -- Suggested mapping from fuzzy logic
    approved_master_key TEXT, -- What YOU approve it maps to
    confidence REAL, -- How confident the suggestion was
    suggestion_reason TEXT, -- Why this was suggested
    approval_status TEXT CHECK(approval_status IN ('pending', 'approved', 'rejected', 'manual')) DEFAULT 'pending',
    your_notes TEXT, -- Your notes about this mapping
    date_suggested DATE DEFAULT (date('now')),
    date_approved DATE,
    reviewed_by TEXT DEFAULT 'Brian' -- You!
);
INSERT INTO pantry_mapping_approvals VALUES(1,'Albacore Tuna In Water',NULL,NULL,0.0,'Pattern match suggestion','approved','Brian approved - correct match','2025-06-02','2025-06-02','Brian');
INSERT INTO pantry_mapping_approvals VALUES(2,'Vienna Sausage',NULL,'vienna_sausage',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(3,'Dongwon Salted Cabbage Kimchi 5.7 Oz',NULL,'kimchi',0.0,'Pattern match suggestion','approved','Auto-approved via cross-reference','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(4,'Bamboo Shoots',NULL,'bamboo_shoots',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(5,'Whole Water Chestnuts',NULL,'water_chestnuts',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(6,'Dijon mustard','dijon_mustard','dijon_mustard',0.949999999999999956,'Exact name match','approved','Bulk approved - had suggested mapping','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(7,'Lemon Pepper',NULL,'lemon_pepper',0.0,'Pattern match suggestion','approved','Auto-approved via cross-reference','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(8,'White Kidney Bean',NULL,'white_kidney_beans',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(9,'Chicken Bouillon Cubes',NULL,'bouillon_cubes',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(10,'Black Peppercorns','black_pepper_ground','black_pepper_ground',0.75,'Contains "black" and "pepper"','approved','Bulk approved - had suggested mapping','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(11,'Organic Ground Turmeric',NULL,'turmeric',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(12,'Mama Sita''s Sinigang Mix',NULL,NULL,0.0,'Pattern match suggestion','pending',NULL,'2025-06-02',NULL,'Brian');
INSERT INTO pantry_mapping_approvals VALUES(13,'Taco Seasoning Mix',NULL,'taco_seasoning',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(14,'Bay Leaves Whole',NULL,'bay_leaves',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(15,'Soy sauce',NULL,'soy_sauce',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(16,'Seed Chia',NULL,'chia_seeds',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(17,'Garlic Salt','garlic_salt','garlic_salt',0.8000000000000000444,'Pattern match suggestion','approved','Bulk approved - had suggested mapping','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(18,'Parsley flakes',NULL,'parsley_dried',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(19,'Crispy fry spicy',NULL,NULL,0.0,'Pattern match suggestion','pending',NULL,'2025-06-02',NULL,'Brian');
INSERT INTO pantry_mapping_approvals VALUES(20,'Datu Puti Vinegar',NULL,'vinegar_asian',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(21,'Pompeian Organic Smooth Extra Virgin Olive Oil, 32 Fl Oz','olive_oil','olive_oil',0.75,'Contains "olive" and "oil"','approved','Bulk approved - had suggested mapping','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(22,'red wine vinegar','red_wine_vinegar','red_wine_vinegar',0.0,'Pattern match suggestion','approved','Bulk approved - had suggested mapping','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(23,'Worcestershire Sauce',NULL,'worcestershire_sauce',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(24,'Power Up Trail Mix, Protein',NULL,NULL,0.0,'Pattern match suggestion','pending',NULL,'2025-06-02',NULL,'Brian');
INSERT INTO pantry_mapping_approvals VALUES(25,'Uncle Ben''s Long Grain & Wild Rice',NULL,'rice_wild',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(26,'Jasmine Rice',NULL,'rice_jasmine',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(27,'Chocolate Hazelnut Spread',NULL,'chocolate_spread',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(28,'Nescafe Gold',NULL,NULL,0.0,'Pattern match suggestion','pending',NULL,'2025-06-02',NULL,'Brian');
INSERT INTO pantry_mapping_approvals VALUES(29,'Oil',NULL,'olive_oil',0.0,'Pattern match suggestion','approved','Auto-approved via cross-reference','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(30,'coconut milk',NULL,'milk',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(31,'Honey',NULL,'honey',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(32,'Black Sesame seeds',NULL,'sesame_seeds',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(33,'Tomato Paste',NULL,'tomatoes_canned',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(34,'Red Hot Sauce',NULL,'hot_sauce',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(35,'Dried Shiitake Mushrooms',NULL,'mushrooms',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(36,'Baking Soda',NULL,'baking_soda',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(37,'Sesame Oil',NULL,'sesame_oil',0.0,'Pattern match suggestion','approved','Auto-approved via cross-reference','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(38,'Lee Kum Kee Hoisin Sauce 8oz',NULL,'hoisin_sauce',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(39,'Banana Chips',NULL,'bananas',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(40,'Oyster flavored Sauce',NULL,'oyster_sauce',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(41,'Brown Rice',NULL,'rice_brown',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(42,'Tomato Ketchup',NULL,'ketchup',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(43,'Tamarind Concentrate',NULL,NULL,0.0,'Pattern match suggestion','pending',NULL,'2025-06-02',NULL,'Brian');
INSERT INTO pantry_mapping_approvals VALUES(44,'Crushed Red Pepper',NULL,'crushed_red_pepper',0.0,'Pattern match suggestion','approved','Auto-approved via cross-reference','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(45,'Organic Chili Powder',NULL,'chili_powder',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(46,'Organic Garlic Powder','garlic_powder','garlic_powder',0.8499999999999999778,'Contains "garlic" and "powder"','approved','Bulk approved - had suggested mapping','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(47,'Pam Organic Olive Oil Cooking spray 5oz','olive_oil','olive_oil',0.75,'Contains "olive" and "oil"','approved','Bulk approved - had suggested mapping','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(48,'Whole Wheat Pasta Fusilli',NULL,'bread_whole_wheat',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(49,'Crushed Tomatoes',NULL,'tomatoes_canned',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(50,'Organic Tomato Sauce',NULL,'tomatoes_canned',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(51,'Diced Tomatoes',NULL,'tomatoes_canned',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(52,'Regular Cheerios',NULL,'breakfast_cereal',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(53,'Prune Juice',NULL,NULL,0.0,'Pattern match suggestion','pending',NULL,'2025-06-02',NULL,'Brian');
INSERT INTO pantry_mapping_approvals VALUES(54,'Asian Pears',NULL,NULL,0.0,'Pattern match suggestion','pending',NULL,'2025-06-02',NULL,'Brian');
INSERT INTO pantry_mapping_approvals VALUES(55,'Red Bell Pepper',NULL,'bell_pepper_red',0.0,'Pattern match suggestion','approved','Auto-approved via cross-reference','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(56,'Green Bell Pepper',NULL,'bell_pepper_green',0.0,'Pattern match suggestion','approved','Auto-approved via cross-reference','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(57,'Yellow Bell Pepper',NULL,'bell_pepper_yellow',0.0,'Pattern match suggestion','approved','Auto-approved via cross-reference','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(58,'Orange Bell Pepper',NULL,'bell_pepper_orange',0.0,'Pattern match suggestion','approved','Auto-approved via cross-reference','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(59,'Limes',NULL,'limes',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(60,'Lemons',NULL,'lemons',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(61,'White Onions',NULL,'onions_white',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(62,'Yellow Onions',NULL,'onions_yellow',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(63,'Red Onions',NULL,'onions_red',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(64,'Sweet Onions',NULL,'onions_yellow',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(65,'Garlic','garlic_fresh','garlic_fresh',0.949999999999999956,'Pattern match suggestion','approved','Bulk approved - had suggested mapping','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(66,'Green Onions',NULL,'green_onions',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(67,'Ginger',NULL,'ginger',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(68,'Cilantro',NULL,'cilantro',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(69,'Thai Basil',NULL,'basil',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(70,'Carrots',NULL,'carrots',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(71,'Celery',NULL,'celery',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(72,'Tomatoes',NULL,'tomatoes_fresh',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(73,'Cherry Tomatoes',NULL,'tomatoes_fresh',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(74,'Cucumber',NULL,'cucumber',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(75,'Zucchini',NULL,'zucchini',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(76,'Mushrooms',NULL,'mushrooms',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(77,'Potatoes',NULL,'potatoes',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(78,'Sweet Potatoes',NULL,'potatoes',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(79,'Russet Potatoes',NULL,'potatoes',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(80,'Red Potatoes',NULL,'potatoes',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(81,'Bananas',NULL,'bananas',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(82,'Apples',NULL,'apples',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(83,'Oranges',NULL,NULL,0.0,'Pattern match suggestion','pending',NULL,'2025-06-02',NULL,'Brian');
INSERT INTO pantry_mapping_approvals VALUES(84,'Green Beans',NULL,'green_beans',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(85,'Broccoli',NULL,'broccoli',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(86,'Cauliflower',NULL,'cauliflower',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(87,'Spinach',NULL,'spinach',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(88,'Lettuce',NULL,'lettuce',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(89,'Cabbage',NULL,'cabbage',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(90,'Bok Choy',NULL,'bok_choy',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(91,'Asparagus',NULL,'asparagus',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(92,'Brussels Sprouts',NULL,'brussels_sprouts',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(93,'Eggplant',NULL,'eggplant',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(94,'Corn',NULL,'corn',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(95,'Avocados',NULL,'avocados',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(96,'Ground Beef',NULL,'ground_beef',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(97,'Ground Turkey',NULL,'ground_turkey',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(98,'Chicken Breast',NULL,'chicken_breast',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(99,'Chicken Thighs',NULL,'chicken_thighs',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(100,'Pork Chops','pork_chops','pork_chops',0.8499999999999999778,'Contains "pork" and "chop"','approved','Bulk approved - had suggested mapping','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(101,'Salmon Fillets',NULL,'salmon_fillets',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(102,'Shrimp',NULL,'shrimp',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(103,'Bacon',NULL,'bacon',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(104,'Italian Sausage',NULL,'italian_sausage',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(105,'Eggs',NULL,'eggs',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(106,'Milk',NULL,'milk',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(107,'Heavy Cream',NULL,'heavy_cream',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(108,'Butter',NULL,'butter',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(109,'Cheese - Cheddar',NULL,'cheese_cheddar',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(110,'Cheese - Mozzarella',NULL,'cheese_mozzarella',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(111,'Cheese - Parmesan',NULL,'cheese_parmesan',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(112,'Greek Yogurt',NULL,'yogurt_greek',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(113,'Cream Cheese',NULL,'cream_cheese',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(114,'Bread - White',NULL,'bread_white',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(115,'Bread - Whole Wheat',NULL,'bread_whole_wheat',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(116,'Flour - All Purpose',NULL,'flour',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(117,'Sugar - White',NULL,'sugar_white',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(118,'Sugar - Brown',NULL,'sugar_brown',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(119,'Vanilla Extract',NULL,'vanilla_extract',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(120,'Baking Powder',NULL,'baking_powder',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(121,'Salt','salt_table','salt_table',0.9000000000000000222,'Pattern match suggestion','approved','Bulk approved - had suggested mapping','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(122,'Black Pepper','black_pepper_ground','black_pepper_ground',0.75,'Contains "black" and "pepper"','approved','Bulk approved - had suggested mapping','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(123,'Paprika',NULL,'paprika_regular',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(124,'Cumin',NULL,'cumin',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(125,'Oregano',NULL,'oregano',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(126,'Thyme',NULL,'thyme',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(127,'Rosemary',NULL,'rosemary',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(128,'Basil',NULL,'basil',0.0,'Pattern match suggestion','approved','Auto-approved via expanded ingredient library','2025-06-02','2025-06-03','Brian');
INSERT INTO pantry_mapping_approvals VALUES(129,'Cinnamon',NULL,'cinnamon',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(130,'Nutmeg',NULL,'nutmeg',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(131,'Garam Masala',NULL,'garam_masala',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(132,'Curry Powder',NULL,'curry_powder',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(133,'Chinese Five Spice',NULL,'chinese_five_spice',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(134,'Italian Seasoning',NULL,'italian_seasoning',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 3 elite club push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(135,'Onion Powder',NULL,'onion_powder',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(136,'Cayenne Pepper',NULL,'cayenne_pepper',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 2 power push','2025-06-02','2025-06-04','Brian');
INSERT INTO pantry_mapping_approvals VALUES(137,'Smoked Paprika',NULL,'paprika_regular',0.0,'Pattern match suggestion','approved','Auto-approved via Phase 1 master ingredients','2025-06-02','2025-06-04','Brian');
CREATE TABLE conversation_sessions (
    session_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_date DATE NOT NULL,
    session_title TEXT,
    session_duration_estimate TEXT, -- "2 hours", "45 minutes"
    major_accomplishments TEXT,
    key_decisions TEXT,
    problems_solved TEXT,
    next_session_goals TEXT,
    session_status TEXT CHECK(session_status IN ('active', 'completed', 'paused')) DEFAULT 'active',
    notes TEXT
);
INSERT INTO conversation_sessions VALUES(1,'2025-06-01','Foundation: Recipe Database & Auto-Tagging System',NULL,'Built complete SQLite recipe database with auto-tagging, personal profiles for Brian & Lilibeth, pantry integration from KitchenPal','User wants manual control over all ingredient mappings. No automatic fuzzy matching. Pork chops ≠ pork tenderloin principle established.','Solved file upload confusion (SQLite .db files DO work with Claude Desktop + button). Optimized bulk INSERT vs individual INSERTs for performance.','Continue building ingredient mapping approval workflow and test with more recipes.','completed',NULL);
INSERT INTO conversation_sessions VALUES(2,'2025-06-02','Ingredient Mapping & Approval System',NULL,'Created master ingredients system, pantry mapping approvals workflow, imported all 306 KitchenPal items, approved first ingredient mapping (Dijon mustard)','Recipe queue strategy: Only check ingredients when moving recipes to active cooking queue. Reduces maintenance overhead significantly.','Clarified SQLite vs Excel differences using analogies. Built approval workflow that gives user complete control over ingredient mappings.','Build recipe queue system, create new recipe ingredient checker, continue ingredient approvals, develop shopping list generator.','completed',NULL);
INSERT INTO conversation_sessions VALUES(3,'2025-06-03','Alternative Names Cross-Reference System Design','45 minutes','Designed complete alternative names system with auto-approval workflow and cross-reference learning','Build ingredient_alternative_names table with auto-approval logic. All manual approvals automatically add to cross-reference for future auto-approval.','Solved the "Dijon Mustard always = dijon mustard" requirement through proper reference system instead of repeated manual approvals','NEXT: 1) Run alternative names system setup, 2) Bulk approve all current mappings, 3) Test auto-approval workflow, 4) Continue with recipe queue system','completed','User wants automated system where manual approvals teach the system for future auto-approvals. Identified 3-phase lifecycle: initial setup → learning phase → mature system with 95%+ auto-approval.');
INSERT INTO conversation_sessions VALUES(4,'2025-06-03','Alternative Names System Implementation & Major Breakthrough','90 minutes','Successfully implemented alternative names system. MASSIVE breakthrough: auto-approval rate jumped from 15.3% to 45.8% (21→68 items approved). Added 30+ common master ingredients. Cut manual work in half.','Unified olive oil naming to just "olive_oil". Created comprehensive master ingredients for fruits, vegetables, dairy, baking, rice, bread. Implemented learning trigger for future auto-approvals.','Fixed foreign key constraint errors by removing FK constraints from alternative names table. Identified that "Other" category (80 items) contained common ingredients missing from master list.','IMMEDIATE NEXT: Run analyze_remaining_75 query to see what categories are left. Create final batch of master ingredients to reach 70%+ auto-approval. Then move to recipe queue system.','paused','This was the breakthrough session where the learning system proved its value. User experienced the learning multiplier effect firsthand. System went from 116 pending to 75 pending items in one execution.');
INSERT INTO conversation_sessions VALUES(5,'2025-06-04','Recipe Queue Stage 1 - Single Recipe Import Success','90 minutes','MAJOR BREAKTHROUGH: Completed ingredients project (306 items, 70+ master ingredients, 4 phases, learning system operational). Successfully imported first recipe with full ingredient linking. Recipe import system proven functional.','Decided to complete ingredients project fully before recipe bulk import. Single recipe test successful - system ready for hundreds of recipes. Recipe import workflow validated.','Fixed Phase 4 syntax errors, completed ingredient automation project, validated recipe import process with Turkey Sausage Breakfast recipe.','NEXT: Assess Phase 5 ingredient gaps vs. bulk recipe import. User has hundreds of recipes in text format ready for CSV conversion and bulk import.','completed','User showed incredible persistence - completed full ingredients automation project from 15% to substantial automation. Recipe system now proven functional. Ready for massive recipe library import.');
INSERT INTO conversation_sessions VALUES(6,'2025-06-04','Recipe Queue Stage 1 - Single Recipe Import Success','90 minutes','MAJOR BREAKTHROUGH: Completed ingredients project (306 items, 70+ master ingredients, 4 phases, learning system operational). Successfully imported first recipe with full ingredient linking. Recipe import system proven functional.','Decided to complete ingredients project fully before recipe bulk import. Single recipe test successful - system ready for hundreds of recipes. Recipe import workflow validated.','Fixed Phase 4 syntax errors, completed ingredient automation project, validated recipe import process with Turkey Sausage Breakfast recipe.','NEXT: Assess Phase 5 ingredient gaps vs. bulk recipe import. User has hundreds of recipes in text format ready for CSV conversion and bulk import.','completed','User showed incredible persistence - completed full ingredients automation project from 15% to substantial automation. Recipe system now proven functional. Ready for massive recipe library import.');
INSERT INTO conversation_sessions VALUES(7,'2025-06-04','Recipe Queue Stage 1 - Single Recipe Import Success','90 minutes','MAJOR BREAKTHROUGH: Completed ingredients project (306 items, 70+ master ingredients, 4 phases, learning system operational). Successfully imported first recipe with full ingredient linking. Recipe import system proven functional.','Decided to complete ingredients project fully before recipe bulk import. Single recipe test successful - system ready for hundreds of recipes. Recipe import workflow validated.','Fixed Phase 4 syntax errors, completed ingredient automation project, validated recipe import process with Turkey Sausage Breakfast recipe.','NEXT: Assess Phase 5 ingredient gaps vs. bulk recipe import. User has hundreds of recipes in text format ready for CSV conversion and bulk import.','completed','User showed incredible persistence - completed full ingredients automation project from 15% to substantial automation. Recipe system now proven functional. Ready for massive recipe library import.');
INSERT INTO conversation_sessions VALUES(8,'2025-06-05','Database Integration Restoration & Expansion Vision','60 minutes','CRITICAL SUCCESS: Restored SQLite MCP integration for persistent database access. Database connection now working across all conversations without file uploads. All Things Food database fully accessible with 26 tables and automation systems operational.','MAJOR DECISION: Expand database architecture beyond food to comprehensive life management system. Transform "All Things Food" to "All Things Brian" supporting work projects, personal goals, home improvement, financial tracking using proven automation patterns.','Fixed MCP server configuration pointing to wrong database file. Troubleshot through VS Code project structure, file locations in iCloud Drive, config file editing, and Claude Desktop restart process. Persistent integration now functional.','NEXT SESSION: 1) Design expansion architecture for multi-project database, 2) Assess Phase 5 ingredient completion vs bulk recipe import decision, 3) Plan unified project management system design, 4) Continue where ingredient automation left off (8 pending items)','completed','BREAKTHROUGH: Achieved persistent database integration without uploads. User recognizes power of proven automation patterns for expansion to all life domains. Food system serves as template for universal project management approach. Integration method documented and working.');
INSERT INTO conversation_sessions VALUES(9,'2025-06-05','Database Integration Restoration & Expansion Vision','60 minutes','CRITICAL SUCCESS: Restored SQLite MCP integration for persistent database access. Database connection now working across all conversations without file uploads. All Things Food database fully accessible with 26 tables and automation systems operational.','MAJOR DECISION: Expand database architecture beyond food to comprehensive life management system. Transform "All Things Food" to "All Things Brian" supporting work projects, personal goals, home improvement, financial tracking using proven automation patterns.','Fixed MCP server configuration pointing to wrong database file. Troubleshot through VS Code project structure, file locations in iCloud Drive, config file editing, and Claude Desktop restart process. Persistent integration now functional.','NEXT SESSION: 1) Design expansion architecture for multi-project database, 2) Assess Phase 5 ingredient completion vs bulk recipe import decision, 3) Plan unified project management system design, 4) Continue where ingredient automation left off (8 pending items)','completed','BREAKTHROUGH: Achieved persistent database integration without uploads. User recognizes power of proven automation patterns for expansion to all life domains. Food system serves as template for universal project management approach. Integration method documented and working.');
INSERT INTO conversation_sessions VALUES(10,'2025-06-05','Database Integration Restoration & Expansion Vision','60 minutes','CRITICAL SUCCESS: Restored SQLite MCP integration for persistent database access. Database connection now working across all conversations without file uploads. All Things Food database fully accessible with 26 tables and automation systems operational.','MAJOR DECISION: Expand database architecture beyond food to comprehensive life management system. Transform "All Things Food" to "All Things Brian" supporting work projects, personal goals, home improvement, financial tracking using proven automation patterns.','Fixed MCP server configuration pointing to wrong database file. Troubleshot through VS Code project structure, file locations in iCloud Drive, config file editing, and Claude Desktop restart process. Persistent integration now functional.','NEXT SESSION: 1) Design expansion architecture for multi-project database, 2) Assess Phase 5 ingredient completion vs bulk recipe import decision, 3) Plan unified project management system design, 4) Continue where ingredient automation left off (8 pending items)','completed','BREAKTHROUGH: Achieved persistent database integration without uploads. User recognizes power of proven automation patterns for expansion to all life domains. Food system serves as template for universal project management approach. Integration method documented and working.');
CREATE TABLE conversation_history (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER,
    memory_type TEXT CHECK(memory_type IN ('decision', 'accomplishment', 'problem', 'insight', 'goal', 'context')),
    topic TEXT,
    content TEXT,
    importance INTEGER CHECK(importance >= 1 AND importance <= 5),
    date_created DATE DEFAULT (date('now')),
    carries_forward BOOLEAN DEFAULT TRUE, -- Should this be remembered in future sessions?
    FOREIGN KEY (session_id) REFERENCES conversation_sessions(session_id)
);
INSERT INTO conversation_history VALUES(1,2,'insight','user_learning_style','User learns best with Excel analogies, step-by-step explanations, avoiding SQL complexity. Prefers manual control over automation. Values clean data quality above convenience.',5,'2025-06-02',1);
INSERT INTO conversation_history VALUES(2,2,'decision','ingredient_mapping','User requires manual approval for ALL ingredient mappings. No automatic fuzzy matching. Each pantry item must be explicitly linked to master ingredients with user approval.',5,'2025-06-02',1);
INSERT INTO conversation_history VALUES(3,2,'insight','pantry_reality','Pantry ingredients are mostly stable (same brands, same products). Only quantities change with shopping/cooking. New variety comes from NEW RECIPES, not pantry changes.',4,'2025-06-02',1);
INSERT INTO conversation_history VALUES(4,2,'decision','recipe_queue_strategy','Store recipes long-term without immediate ingredient checking. Only verify ingredients when moving recipes to active cooking queue. This dramatically reduces maintenance work.',5,'2025-06-02',1);
INSERT INTO conversation_history VALUES(5,2,'accomplishment','bulk_import','Successfully imported 306 KitchenPal pantry items using optimized bulk INSERT. Performance lesson: single statement 10x faster than individual INSERTs.',4,'2025-06-02',1);
INSERT INTO conversation_history VALUES(6,2,'accomplishment','first_approval','Successfully approved first ingredient mapping: Dijon mustard pantry item linked to dijon_mustard master ingredient. User understands approval process.',3,'2025-06-02',1);
INSERT INTO conversation_history VALUES(7,2,'context','technical_understanding','User comfortable with DB Browser navigation: Browse Data = Excel view, Execute SQL = run commands. Understands Database = Workbook, Tables = Worksheets analogy.',4,'2025-06-02',1);
INSERT INTO conversation_history VALUES(8,2,'goal','next_priorities','Next session: Build recipe queue system, create new recipe ingredient checker, continue ingredient approvals, develop shopping list generator based on current quantities.',5,'2025-06-02',1);
INSERT INTO conversation_history VALUES(9,3,'insight','auto_approval_lifecycle','Ingredient approval follows diminishing returns: Phase 1 = high manual work building cross-reference, Phase 2 = medium work catching edge cases, Phase 3 = minimal work (95%+ auto-approval) for truly new ingredients only. Shopping patterns are stable so system learns user brands.',5,'2025-06-03',1);
INSERT INTO conversation_history VALUES(10,3,'decision','alternative_names_system','Create ingredient_alternative_names table with master_ingredient_key, alternative_name, auto_approve flag, and match_type (exact/contains/brand_variation). This replaces manual approval for known variations.',5,'2025-06-03',1);
INSERT INTO conversation_history VALUES(11,3,'decision','learning_system','All manual approvals automatically add pantry_ingredient_name to cross-reference as auto-approved alternative name. System learns from every manual approval and prevents future manual work for same variations.',5,'2025-06-03',1);
INSERT INTO conversation_history VALUES(12,3,'context','current_problem','User has ~100+ pending ingredient mappings that need approval. Many are obvious matches like "Dijon Mustard" → "dijon_mustard" but require individual manual approval. Need automated system.',4,'2025-06-03',1);
INSERT INTO conversation_history VALUES(13,3,'accomplishment','system_design','Designed complete workflow: 1) Create alternative names table with common variations, 2) Auto-approve existing mappings, 3) Auto-approve cross-reference matches, 4) Add all approvals to cross-reference, 5) Set up trigger for future learning.',4,'2025-06-03',1);
INSERT INTO conversation_history VALUES(14,3,'goal','implementation_steps','IMMEDIATE NEXT STEPS: Run alternative_names_system artifact to create tables and populate with common variations. Then run complete_approval_workflow artifact to bulk approve current mappings and populate cross-reference.',5,'2025-06-03',1);
INSERT INTO conversation_history VALUES(15,3,'context','artifacts_created','Created two key artifacts: 1) alternative_names_system (creates tables, populates common variations, sets up auto-approval logic), 2) complete_approval_workflow (bulk approves everything and populates cross-reference). User needs to run these in DB Browser.',4,'2025-06-03',1);
INSERT INTO conversation_history VALUES(16,3,'insight','user_workflow','User shopping patterns are stable - same brands, same stores. Cross-reference will quickly learn user-specific brand mappings. After initial setup, manual approvals will drop to near-zero as system recognizes all regular brands and variations.',4,'2025-06-03',1);
INSERT INTO conversation_history VALUES(17,4,'accomplishment','massive_breakthrough','BREAKTHROUGH SESSION: Auto-approval rate jumped from 15.3% to 45.8% in one script execution. Added 30+ master ingredients for common items (fruits, vegetables, dairy, baking). Proved the learning multiplier effect - each master ingredient auto-approved multiple similar items. System went from 21→68 approved items.',5,'2025-06-03',1);
INSERT INTO conversation_history VALUES(18,4,'decision','olive_oil_simplification','User decided to unify all olive oil types into just "olive_oil" - no separate regular vs extra virgin. This simplifies the ingredient system and matches user mental model. Updated all existing mappings to use unified olive_oil key.',4,'2025-06-03',1);
INSERT INTO conversation_history VALUES(19,4,'insight','other_category_goldmine','The "Other" category with 80 items was actually a goldmine of common ingredients missing from master list. Items like apples, butter, eggs, spinach, potatoes were obvious but needed master ingredients created. This category drove the major breakthrough.',5,'2025-06-03',1);
INSERT INTO conversation_history VALUES(20,4,'accomplishment','learning_system_operational','Learning system is now fully operational with: ingredient_alternative_names table (no FK constraints), auto-approval logic, learning trigger that adds each manual approval to cross-reference. Every future manual approval teaches the system.',4,'2025-06-03',1);
INSERT INTO conversation_history VALUES(21,4,'context','current_status','STATUS: 68 items approved (45.8% rate), 75 items pending, learning system operational. User ready to analyze remaining 75 items for final push to 70%+ auto-approval. analyze_remaining_75 query ready to run.',5,'2025-06-03',1);
INSERT INTO conversation_history VALUES(22,4,'goal','final_push_next','NEXT SESSION PRIORITY: Run analyze_remaining_75 query to see remaining categories. Create final batch of master ingredients (likely tomatoes, onions, cheese, sauces, meats). Target: reach 70%+ auto-approval rate. Then proceed to recipe queue system.',5,'2025-06-03',1);
INSERT INTO conversation_history VALUES(23,4,'insight','learning_multiplier_proven','User experienced the learning multiplier effect: adding 30 master ingredients auto-approved 47 pantry items. Each strategic master ingredient had 1.5x impact. This proves the diminishing returns model - initial work pays exponential dividends.',4,'2025-06-03',1);
INSERT INTO conversation_history VALUES(24,4,'decision','no_foreign_keys','Removed foreign key constraints from ingredient_alternative_names table to avoid constraint errors. System still works perfectly for auto-approval without referential integrity enforcement. Pragmatic solution that prioritizes functionality.',3,'2025-06-03',1);
CREATE TABLE ingredient_alternative_names (
    alt_name_id INTEGER PRIMARY KEY AUTOINCREMENT,
    master_ingredient_key TEXT NOT NULL,
    alternative_name TEXT NOT NULL,
    auto_approve BOOLEAN DEFAULT TRUE,
    match_type TEXT CHECK(match_type IN ('exact', 'contains', 'brand_variation')),
    confidence INTEGER DEFAULT 100,
    notes TEXT,
    date_added DATE DEFAULT (date('now')),
    UNIQUE(master_ingredient_key, alternative_name)
);
INSERT INTO ingredient_alternative_names VALUES(1,'dijon_mustard','Dijon Mustard',1,'exact',100,'Standard capitalization','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(2,'dijon_mustard','dijon mustard',1,'exact',100,'Lowercase version','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(3,'dijon_mustard','Dijon mustard',1,'exact',100,'Mixed case','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(4,'olive_oil','Olive Oil',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(5,'olive_oil','Oil',1,'exact',100,'Generic oil reference','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(6,'olive_oil','olive oil',1,'exact',100,'Lowercase version','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(7,'olive_oil','Extra Virgin Olive Oil',1,'exact',100,'EVOO type','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(8,'olive_oil','EVOO',1,'exact',100,'Common abbreviation','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(9,'olive_oil','Pompeian Organic Smooth Extra Virgin Olive Oil',1,'contains',100,'Specific brand','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(10,'garlic_fresh','Garlic',1,'exact',100,'Simple name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(11,'garlic_fresh','Fresh Garlic',1,'exact',100,'With descriptor','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(12,'garlic_powder','Garlic Powder',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(13,'garlic_powder','Organic Garlic Powder',1,'contains',100,'With organic prefix','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(14,'garlic_salt','Garlic Salt',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(15,'black_pepper_ground','Black Pepper',1,'exact',100,'Simple name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(16,'black_pepper_ground','Ground Black Pepper',1,'exact',100,'With descriptor','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(17,'black_peppercorns_whole','Black Peppercorns',1,'exact',100,'Simple name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(18,'black_peppercorns_whole','Whole Black Peppercorns',1,'exact',100,'With descriptor','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(19,'salt_table','Salt',1,'exact',100,'Simple name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(20,'salt_table','Table Salt',1,'exact',100,'With descriptor','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(21,'red_wine_vinegar','Red Wine Vinegar',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(22,'red_wine_vinegar','red wine vinegar',1,'exact',100,'Lowercase','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(23,'balsamic_vinegar','Balsamic Vinegar',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(24,'pork_tenderloin','Pork Tenderloin',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(25,'pork_chops','Pork Chops',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(26,'lemon_pepper','Lemon Pepper',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(27,'crushed_red_pepper','Crushed Red Pepper',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(28,'sesame_oil','Sesame Oil',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(29,'bell_pepper_red','Red Bell Pepper',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(30,'bell_pepper_green','Green Bell Pepper',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(31,'bell_pepper_yellow','Yellow Bell Pepper',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(32,'bell_pepper_orange','Orange Bell Pepper',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(33,'kimchi','Kimchi',1,'contains',100,'Any kimchi product','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(34,'kimchi','Salted Cabbage Kimchi',1,'contains',100,'Specific kimchi type','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(35,'kimchi','Dongwon Salted Cabbage Kimchi 5.7 Oz',1,'exact',95,'Added from approval on 2025-06-03','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(38,'black_pepper_ground','Black Peppercorns',1,'exact',95,'Added from approval on 2025-06-03','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(40,'olive_oil','Pompeian Organic Smooth Extra Virgin Olive Oil, 32 Fl Oz',1,'exact',95,'Added from approval on 2025-06-03','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(46,'olive_oil','Pam Organic Olive Oil Cooking spray 5oz',1,'exact',95,'Added from approval on 2025-06-03','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(55,'apples','Apples',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(56,'avocados','Avocados',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(57,'bananas','Bananas',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(58,'bananas','Banana Chips',1,'contains',100,'Banana product','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(59,'lemons','Lemons',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(60,'limes','Limes',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(61,'broccoli','Broccoli',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(62,'carrots','Carrots',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(63,'celery','Celery',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(64,'mushrooms','Mushrooms',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(65,'mushrooms','Dried Shiitake Mushrooms',1,'contains',100,'Mushroom variety','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(66,'spinach','Spinach',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(67,'potatoes','Potatoes',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(68,'potatoes','Red Potatoes',1,'contains',100,'Potato variety','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(69,'potatoes','Russet Potatoes',1,'contains',100,'Potato variety','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(70,'potatoes','Sweet Potatoes',1,'contains',100,'Potato variety','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(71,'corn','Corn',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(72,'cabbage','Cabbage',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(73,'cabbage','Salted Cabbage Kimchi',1,'contains',100,'Cabbage product','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(74,'green_beans','Green Beans',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(75,'white_kidney_beans','White Kidney Bean',1,'contains',100,'Specific bean type','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(76,'beans','Green Beans',1,'contains',100,'Bean variety','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(77,'basil','Basil',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(78,'basil','Thai Basil',1,'contains',100,'Basil variety','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(79,'cilantro','Cilantro',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(80,'ginger','Ginger',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(81,'butter','Butter',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(82,'eggs','Eggs',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(83,'milk','Milk',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(84,'milk','coconut milk',1,'contains',100,'Milk variety','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(85,'heavy_cream','Heavy Cream',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(86,'cream_cheese','Cream Cheese',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(87,'sugar_white','Sugar - White',1,'contains',100,'White sugar','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(88,'sugar_brown','Sugar - Brown',1,'contains',100,'Brown sugar','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(89,'flour','Flour - All Purpose',1,'contains',100,'All-purpose flour','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(90,'baking_powder','Baking Powder',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(91,'vanilla_extract','Vanilla Extract',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(92,'rice_brown','Brown Rice',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(93,'rice_jasmine','Jasmine Rice',1,'exact',100,'Standard name','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(94,'rice_wild','Uncle Ben''s Long Grain & Wild Rice',1,'contains',100,'Specific rice product','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(95,'bread_white','Bread - White',1,'contains',100,'White bread','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(96,'bread_whole_wheat','Bread - Whole Wheat',1,'contains',100,'Whole wheat bread','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(97,'bread_whole_wheat','Whole Wheat Pasta Fusilli',1,'contains',100,'Whole wheat product','2025-06-03');
INSERT INTO ingredient_alternative_names VALUES(139,'tomatoes_fresh','Tomatoes',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(140,'tomatoes_fresh','Cherry Tomatoes',1,'contains',95,'Cherry tomatoes are fresh tomatoes','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(141,'cherry_tomatoes','Cherry Tomatoes',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(142,'tomatoes_canned','Diced Tomatoes',1,'contains',100,'Canned tomato product','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(143,'tomatoes_canned','Crushed Tomatoes',1,'contains',100,'Canned tomato product','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(144,'tomatoes_canned','Organic Tomato Sauce',1,'contains',95,'Tomato sauce is canned product','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(145,'tomatoes_canned','Tomato Paste',1,'contains',100,'Concentrated tomato product','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(146,'onions_yellow','Yellow Onions',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(147,'onions_yellow','Sweet Onions',1,'contains',90,'Sweet onions usually yellow variety','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(148,'onions_red','Red Onions',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(149,'onions_white','White Onions',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(150,'green_onions','Green Onions',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(151,'cheese_parmesan','Cheese - Parmesan',1,'contains',100,'Parmesan cheese variant','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(152,'cheese_mozzarella','Cheese - Mozzarella',1,'contains',100,'Mozzarella cheese variant','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(153,'cheese_cheddar','Cheese - Cheddar',1,'contains',100,'Cheddar cheese variant','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(154,'yogurt_greek','Greek Yogurt',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(155,'chicken_breast','Chicken Breast',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(156,'chicken_thighs','Chicken Thighs',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(157,'ground_beef','Ground Beef',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(158,'ground_turkey','Ground Turkey',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(159,'eggplant','Eggplant',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(160,'paprika_regular','Paprika',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(161,'paprika_regular','Smoked Paprika',1,'contains',95,'Smoked is paprika variety','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(162,'onion_powder','Onion Powder',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(163,'oregano','Oregano',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(188,'brussels_sprouts','Brussels Sprouts',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(189,'asparagus','Asparagus',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(190,'bok_choy','Bok Choy',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(191,'lettuce','Lettuce',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(192,'cauliflower','Cauliflower',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(193,'zucchini','Zucchini',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(194,'cucumber','Cucumber',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(195,'chili_powder','Organic Chili Powder',1,'contains',95,'Organic chili powder variant','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(196,'cayenne_pepper','Cayenne Pepper',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(197,'turmeric','Organic Ground Turmeric',1,'contains',95,'Organic turmeric variant','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(198,'cinnamon','Cinnamon',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(199,'nutmeg','Nutmeg',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(200,'thyme','Thyme',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(201,'rosemary','Rosemary',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(202,'cumin','Cumin',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(203,'bay_leaves','Bay Leaves Whole',1,'contains',100,'Whole bay leaves variant','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(204,'parsley_dried','Parsley flakes',1,'contains',95,'Dried parsley flakes','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(205,'bacon','Bacon',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(206,'shrimp','Shrimp',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(207,'salmon_fillets','Salmon Fillets',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(208,'italian_sausage','Italian Sausage',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(209,'soy_sauce','Soy sauce',1,'exact',100,'Direct match - lowercase','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(210,'hoisin_sauce','Lee Kum Kee Hoisin Sauce 8oz',1,'contains',95,'Specific brand hoisin sauce','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(211,'oyster_sauce','Oyster flavored Sauce',1,'contains',95,'Oyster sauce variant','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(212,'honey','Honey',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(213,'baking_soda','Baking Soda',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(214,'sesame_seeds','Black Sesame seeds',1,'contains',95,'Black sesame seeds variety','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(242,'italian_seasoning','Italian Seasoning',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(243,'taco_seasoning','Taco Seasoning Mix',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(244,'chinese_five_spice','Chinese Five Spice',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(245,'curry_powder','Curry Powder',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(246,'garam_masala','Garam Masala',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(247,'ketchup','Tomato Ketchup',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(248,'hot_sauce','Red Hot Sauce',1,'contains',95,'Red hot sauce variant','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(249,'worcestershire_sauce','Worcestershire Sauce',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(250,'vinegar_asian','Datu Puti Vinegar',1,'contains',90,'Filipino vinegar brand','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(251,'bouillon_cubes','Chicken Bouillon Cubes',1,'contains',95,'Chicken bouillon variant','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(252,'water_chestnuts','Whole Water Chestnuts',1,'contains',95,'Whole water chestnuts','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(253,'bamboo_shoots','Bamboo Shoots',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(254,'vienna_sausage','Vienna Sausage',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(255,'chia_seeds','Seed Chia',1,'contains',95,'Chia seed variant naming','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(256,'breakfast_cereal','Regular Cheerios',1,'contains',90,'Specific cereal brand','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(257,'chocolate_spread','Chocolate Hazelnut Spread',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(274,'pasta_chickpea','Banza Penne',1,'contains',95,'Chickpea pasta brand','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(275,'pasta_chickpea','Banza Chickpea Spaghetti',1,'contains',95,'Chickpea pasta brand','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(276,'noodles_instant','Nissin Cup Noodles Chicken Flavor 3 Pack',1,'contains',90,'Cup noodles variety','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(277,'noodles_instant','Nissin Beef Flavor Ramen Noodle Soup 6.75 oz',1,'contains',90,'Ramen variety','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(278,'rice_wild_blend','Long Grain & Wild Rice',1,'contains',95,'Rice blend variety','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(279,'rice_seasoned','Chicken Flavored Rice',1,'contains',95,'Flavored rice product','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(280,'milk_condensed','Sweetened Condensed Milk',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(281,'soup_cream_base','maggi, cream of mushroom soup',1,'contains',85,'Cream soup mix','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(282,'soup_cream_base','Soup Mix (Cream of Mushroom)',1,'contains',90,'Cream soup mix','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(283,'soup_cream_base','Campells Cream of Mushroom',1,'contains',90,'Cream soup brand','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(284,'soup_cream_base','Campbells Cream of Mushroom Soup',1,'contains',90,'Cream soup brand','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(285,'chips_chocolate','Milk Chocolate Morsels',1,'contains',95,'Chocolate chip variety','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(286,'chips_chocolate','Chocolate Chips | White Chocolate Chips',1,'contains',100,'Multiple chip varieties','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(287,'chips_chocolate','Bittersweet Chocolate Chips',1,'contains',95,'Chocolate chip variety','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(288,'butter_peanut','Peanut Butter',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(289,'butter_peanut','Reeses Miniature Peanut Butter Cups 35.6-Oz-Bag',1,'contains',80,'Peanut butter product','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(290,'spray_cooking','Pam Cooking Spray - Butter Flavor',1,'contains',95,'Flavored cooking spray','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(291,'products_coconut','Coconut Milk Powder',1,'contains',95,'Coconut product','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(292,'seeds_cooking','El Guapo Coriander Seed (12x1.25OZ )',1,'contains',90,'Specialty seed','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(293,'seeds_cooking','Roasted Sesame Seed',1,'contains',95,'Sesame seed variety','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(294,'nuts_flavored','nagaraya, cracker nuts, garlic',1,'contains',85,'Flavored nut snack','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(295,'miso_soup','white miso soup',1,'contains',95,'Miso soup variety','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(296,'miso_soup','Miso Soup Spinach Tofu',1,'contains',90,'Miso soup variety','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(297,'filipino_foods','Filipino Hotdogs',1,'contains',90,'Filipino specialty item','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(298,'soup_asian','Chinese Style Egg Flower Soup Mix',1,'contains',90,'Asian soup mix','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(299,'soup_asian','Mama Sitas Guava Soup Base Mix',1,'contains',85,'Filipino soup base','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(300,'crackers_whole_grain','Wheat Thins Hint Of Salt Low Sodium Whole Grain Snacks - 9.1oz',1,'contains',90,'Specialty cracker','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(301,'mix_breading','Crispy Fry Chicken Breading Mix',1,'contains',95,'Breading mix','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(302,'yeast_baking','Active Dry Yeast',1,'exact',100,'Direct match','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(303,'yeast_baking','Red Star Active Dry Yeast',1,'contains',95,'Yeast brand','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(304,'sugar_brown_varieties','Dark brown sugar',1,'contains',95,'Brown sugar variety','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(305,'tuna_flavored','Tuna Creations - Herb & Garlic',1,'contains',90,'Flavored tuna variety','2025-06-04');
INSERT INTO ingredient_alternative_names VALUES(306,'meat_deli','Roast Beef',1,'exact',100,'Direct match','2025-06-04');
CREATE TABLE projects (
    project_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_name TEXT NOT NULL UNIQUE,
    project_description TEXT,
    status TEXT DEFAULT 'active',
    created_date DATE DEFAULT (date('now')),
    last_updated DATE DEFAULT (date('now'))
);
INSERT INTO projects VALUES(1,'food_management','Recipe and meal planning system with ingredients automation','active','2025-06-06','2025-06-06');
INSERT INTO projects VALUES(2,'smart_home','Lillibeths Command Center and home automation','active','2025-06-06','2025-06-06');
CREATE TABLE hardware_components (
    component_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER,
    component_name TEXT NOT NULL,
    model_number TEXT,
    manufacturer TEXT,
    category TEXT, -- pi, sensor, display, hub, storage, etc.
    specifications TEXT, -- JSON or detailed specs
    purchase_date DATE,
    warranty_info TEXT,
    location TEXT,
    status TEXT DEFAULT 'active', -- active, testing, failed, retired
    network_address TEXT, -- IP address if applicable
    mac_address TEXT,
    notes TEXT,
    created_date DATE DEFAULT (date('now')),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);
CREATE TABLE software_components (
    software_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER,
    component_id INTEGER, -- links to hardware if applicable
    software_name TEXT NOT NULL,
    version TEXT,
    software_type TEXT, -- os, firmware, app, service, etc.
    installation_date DATE,
    update_available BOOLEAN DEFAULT FALSE,
    last_updated DATE,
    compatibility_notes TEXT,
    configuration_backup TEXT, -- file path or config dump
    status TEXT DEFAULT 'active',
    notes TEXT,
    created_date DATE DEFAULT (date('now')),
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (component_id) REFERENCES hardware_components(component_id)
);
CREATE TABLE project_phases (
    phase_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER,
    phase_name TEXT NOT NULL,
    phase_description TEXT,
    status TEXT DEFAULT 'planned', -- planned, in_progress, completed, blocked
    start_date DATE,
    target_completion_date DATE,
    actual_completion_date DATE,
    dependencies TEXT, -- phase_ids this depends on
    success_criteria TEXT,
    notes TEXT,
    created_date DATE DEFAULT (date('now')),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);
CREATE TABLE system_integrations (
    integration_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER,
    integration_name TEXT NOT NULL,
    system_a_id INTEGER, -- hardware or software component
    system_b_id INTEGER, -- hardware or software component  
    integration_type TEXT, -- api, direct_connect, protocol, etc.
    protocol TEXT, -- zigbee, wifi, bluetooth, http, etc.
    configuration TEXT, -- connection details, API keys, etc.
    status TEXT DEFAULT 'planned', -- planned, configured, tested, active, failed
    last_tested DATE,
    test_results TEXT,
    troubleshooting_notes TEXT,
    created_date DATE DEFAULT (date('now')),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);
CREATE TABLE project_issues (
    issue_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER,
    component_id INTEGER, -- optional link to specific hardware/software
    issue_title TEXT NOT NULL,
    issue_description TEXT,
    issue_category TEXT, -- compatibility, networking, configuration, hardware_failure, etc.
    severity TEXT DEFAULT 'medium', -- low, medium, high, critical
    status TEXT DEFAULT 'open', -- open, investigating, resolved, closed, wont_fix
    reported_date DATE DEFAULT (date('now')),
    resolved_date DATE,
    resolution_description TEXT,
    lessons_learned TEXT,
    research_sources TEXT, -- URLs, forum posts, documentation used
    created_by TEXT DEFAULT 'user',
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (component_id) REFERENCES hardware_components(component_id)
);
CREATE TABLE network_config (
    config_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER,
    device_name TEXT NOT NULL,
    ip_address TEXT,
    mac_address TEXT,
    hostname TEXT,
    port_numbers TEXT, -- JSON array of ports used
    network_type TEXT, -- wifi, ethernet, zigbee, bluetooth
    security_config TEXT, -- authentication methods, certificates
    bandwidth_requirements TEXT,
    uptime_requirements TEXT,
    backup_config TEXT,
    last_verified DATE,
    status TEXT DEFAULT 'active',
    notes TEXT,
    created_date DATE DEFAULT (date('now')),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);
DELETE FROM sqlite_sequence;
INSERT INTO sqlite_sequence VALUES('user_preferences',5);
INSERT INTO sqlite_sequence VALUES('conversation_memory',36);
INSERT INTO sqlite_sequence VALUES('recipes',3);
INSERT INTO sqlite_sequence VALUES('ingredients',23);
INSERT INTO sqlite_sequence VALUES('instructions',5);
INSERT INTO sqlite_sequence VALUES('recipe_feedback',1);
INSERT INTO sqlite_sequence VALUES('tags',49);
INSERT INTO sqlite_sequence VALUES('tagging_rules',34);
INSERT INTO sqlite_sequence VALUES('people',4);
INSERT INTO sqlite_sequence VALUES('allergies',10);
INSERT INTO sqlite_sequence VALUES('food_preferences',6);
INSERT INTO sqlite_sequence VALUES('kitchen_equipment',5);
INSERT INTO sqlite_sequence VALUES('pantry_items',148);
INSERT INTO sqlite_sequence VALUES('master_ingredients',175);
INSERT INTO sqlite_sequence VALUES('pantry_mapping_approvals',137);
INSERT INTO sqlite_sequence VALUES('conversation_sessions',10);
INSERT INTO sqlite_sequence VALUES('conversation_history',24);
INSERT INTO sqlite_sequence VALUES('ingredient_alternative_names',306);
INSERT INTO sqlite_sequence VALUES('projects',2);
CREATE VIEW recipe_summary AS
SELECT 
    r.recipe_id,
    r.name,
    r.cuisine_type,
    r.total_time_minutes,
    r.times_made,
    AVG(rf.rating) as avg_rating,
    COUNT(rf.feedback_id) as feedback_count,
    r.date_last_made
FROM recipes r
LEFT JOIN recipe_feedback rf ON r.recipe_id = rf.recipe_id
GROUP BY r.recipe_id, r.name, r.cuisine_type, r.total_time_minutes, r.times_made, r.date_last_made;
CREATE VIEW shopping_list_complete AS
SELECT 
    sl.name as list_name,
    sl.date_created,
    COUNT(sli.item_id) as total_items,
    SUM(CASE WHEN sli.purchased THEN 1 ELSE 0 END) as purchased_items,
    ROUND((SUM(CASE WHEN sli.purchased THEN 1 ELSE 0 END) * 100.0) / COUNT(sli.item_id), 2) as percent_complete
FROM shopping_lists sl
LEFT JOIN shopping_list_items sli ON sl.list_id = sli.list_id
GROUP BY sl.list_id, sl.name, sl.date_created;
CREATE VIEW recipe_with_tags AS
SELECT 
    r.recipe_id,
    r.name,
    r.cuisine_type,
    r.total_time_minutes,
    r.servings,
    r.difficulty_level,
    GROUP_CONCAT(t.tag_name, ', ') as tags,
    COUNT(t.tag_name) as tag_count
FROM recipes r
LEFT JOIN recipe_tags rt ON r.recipe_id = rt.recipe_id
LEFT JOIN tags t ON rt.tag_id = t.tag_id
GROUP BY r.recipe_id, r.name, r.cuisine_type, r.total_time_minutes, r.servings, r.difficulty_level;
CREATE VIEW auto_tag_suggestions AS
SELECT DISTINCT
    r.recipe_id,
    r.name,
    tr.tag_name,
    tr.confidence,
    tr.rule_name
FROM recipes r
CROSS JOIN tagging_rules tr
WHERE tr.active = 1
AND (
    -- Time rules
    (tr.condition_type = 'time' AND tr.condition_value = '<=30' AND r.total_time_minutes <= 30) OR
    (tr.condition_type = 'time' AND tr.condition_value = '<=15' AND r.total_time_minutes <= 15) OR
    
    -- Serving rules  
    (tr.condition_type = 'servings' AND tr.condition_value = '<=2' AND r.servings <= 2) OR
    (tr.condition_type = 'servings' AND tr.condition_value = '>=4' AND r.servings >= 4) OR
    
    -- Keyword rules - simple LIKE matching
    (tr.condition_type = 'keyword' AND LOWER(r.name) LIKE '%' || LOWER(tr.condition_value) || '%')
)
-- Don't suggest tags already applied
AND tr.tag_name NOT IN (
    SELECT t.tag_name FROM recipe_tags rt
    JOIN tags t ON rt.tag_id = t.tag_id  
    WHERE rt.recipe_id = r.recipe_id
)
;
CREATE VIEW pantry_summary AS
SELECT 
    location,
    COUNT(*) as item_count,
    COUNT(CASE WHEN expiry_date IS NOT NULL THEN 1 END) as items_with_expiry,
    COUNT(CASE WHEN level = 'full' THEN 1 END) as full_items,
    COUNT(CASE WHEN level = 'half' THEN 1 END) as half_items
FROM pantry_items;
CREATE VIEW pending_approvals AS
SELECT 
    pma.approval_id,
    pma.pantry_ingredient_name,
    pma.suggested_master_key,
    mi.display_name as suggested_ingredient,
    mi.category,
    mi.subcategory,
    pma.confidence,
    pma.suggestion_reason,
    pma.approval_status
FROM pantry_mapping_approvals pma
LEFT JOIN master_ingredients mi ON pma.suggested_master_key = mi.ingredient_key
WHERE pma.approval_status = 'pending'
ORDER BY pma.confidence DESC, pma.pantry_ingredient_name;
CREATE VIEW approved_mappings AS
SELECT 
    pma.pantry_ingredient_name,
    mi.ingredient_key,
    mi.display_name,
    mi.category,
    pma.your_notes,
    pma.date_approved
FROM pantry_mapping_approvals pma
JOIN master_ingredients mi ON pma.approved_master_key = mi.ingredient_key
WHERE pma.approval_status = 'approved'
ORDER BY mi.category, mi.display_name;
CREATE VIEW session_summary AS
SELECT 
    cs.session_id,
    cs.session_date,
    cs.session_title,
    cs.major_accomplishments,
    cs.key_decisions,
    cs.session_status,
    COUNT(ch.history_id) as memory_items_stored
FROM conversation_sessions cs
LEFT JOIN conversation_history ch ON cs.session_id = ch.session_id
GROUP BY cs.session_id, cs.session_date, cs.session_title, cs.major_accomplishments, cs.key_decisions, cs.session_status
ORDER BY cs.session_date DESC;
CREATE VIEW key_decisions_timeline AS
SELECT 
    cs.session_date,
    cs.session_title,
    ch.topic,
    ch.content as decision,
    ch.importance
FROM conversation_history ch
JOIN conversation_sessions cs ON ch.session_id = cs.session_id
WHERE ch.memory_type = 'decision' AND ch.carries_forward = TRUE
ORDER BY cs.session_date, ch.importance DESC;
CREATE VIEW next_session_context AS
SELECT 
    'SYSTEM CONTEXT FOR NEXT CONVERSATION' as section,
    topic,
    content,
    CASE importance 
        WHEN 5 THEN 'CRITICAL - Must Remember'
        WHEN 4 THEN 'Important - High Priority'  
        WHEN 3 THEN 'Useful - Medium Priority'
        ELSE 'Optional - Low Priority'
    END as priority_level
FROM conversation_history 
WHERE carries_forward = TRUE 
AND session_id = (SELECT MAX(session_id) FROM conversation_sessions)
ORDER BY importance DESC, memory_type;
CREATE TRIGGER auto_add_to_crossref 
AFTER UPDATE ON pantry_mapping_approvals
FOR EACH ROW
WHEN NEW.approval_status = 'approved' 
AND OLD.approval_status = 'pending'
AND NEW.approved_master_key IS NOT NULL
BEGIN
    INSERT OR IGNORE INTO ingredient_alternative_names 
    (master_ingredient_key, alternative_name, match_type, auto_approve, notes, confidence)
    VALUES 
    (NEW.approved_master_key, NEW.pantry_ingredient_name, 'exact', TRUE, 
     'Auto-added from manual approval on ' || date('now'), 95);
END;
CREATE VIEW smart_home_memory AS
SELECT cm.*, p.project_name
FROM conversation_memory cm
JOIN projects p ON cm.project_id = p.project_id
WHERE p.project_name = 'smart_home'
ORDER BY cm.date_created DESC;
CREATE VIEW food_management_memory AS
SELECT cm.*, p.project_name  
FROM conversation_memory cm
JOIN projects p ON cm.project_id = p.project_id
WHERE p.project_name = 'food_management'
ORDER BY cm.date_created DESC;
CREATE VIEW project_status_overview AS
SELECT 
    p.project_name,
    p.status as project_status,
    COUNT(DISTINCT hc.component_id) as hardware_count,
    COUNT(DISTINCT sc.software_id) as software_count,
    COUNT(DISTINCT pp.phase_id) as total_phases,
    COUNT(DISTINCT CASE WHEN pp.status = 'completed' THEN pp.phase_id END) as completed_phases,
    COUNT(DISTINCT CASE WHEN pi.status = 'open' THEN pi.issue_id END) as open_issues,
    COUNT(DISTINCT si.integration_id) as total_integrations,
    COUNT(DISTINCT CASE WHEN si.status = 'active' THEN si.integration_id END) as active_integrations
FROM projects p
LEFT JOIN hardware_components hc ON p.project_id = hc.project_id
LEFT JOIN software_components sc ON p.project_id = sc.project_id  
LEFT JOIN project_phases pp ON p.project_id = pp.project_id
LEFT JOIN project_issues pi ON p.project_id = pi.project_id
LEFT JOIN system_integrations si ON p.project_id = si.project_id
GROUP BY p.project_id, p.project_name, p.status;
COMMIT;
