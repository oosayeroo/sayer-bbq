
Discord - https://discord.gg/3WYz3zaqG5

# A BBQ Script for QBCore Framework

## Please note

- Please make sure u use the latest dependencies aswell as core for this in order to work.

- This Job has been tested on the latest build as of 20/12/23.


## Dependencies :

QBCore Framework - https://github.com/qbcore-framework/qb-core

PolyZone - https://github.com/mkafrin/PolyZone

qb-target - https://github.com/BerkieBb/qb-target

qb-menu - https://github.com/qbcore-framework/qb-menu

## Common Issues 
```
1. My Cook Menu wont load up?
1. 99% of the time its an issue with your Shared/Items.lua. (missing item or duplicate item)
```

## Credits : 

- Breadlord as this was his original idea and he gave me permission to do it instead. 

## Run the sql file 'sayer_bbqs.sql' 

## Insert into @qb-core/shared/items.lua 

```
QBShared.Items = {
--SAYER BBQ
   -- FOOD
    ['burger'] 			            = {['name'] = 'burger', 		        	    ['label'] = 'Beef Burger', 		    ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'burger.png', 	        	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['uncooked_burger'] 			= {['name'] = 'uncooked_burger', 		        ['label'] = 'Raw Burger', 	        ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'uncooked_burger.png', 	   	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['chicken'] 			        = {['name'] = 'chicken', 		           	    ['label'] = 'Chicken Burger', 	    ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'chicken.png', 	        	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['uncooked_chicken'] 			= {['name'] = 'uncooked_chicken', 		        ['label'] = 'Raw Chicken Burger',   ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'uncooked_chicken.png',    	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['hotdog'] 			            = {['name'] = 'hotdog', 		        	   	['label'] = 'HotDog', 		        ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'hotdog.png', 	        	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['uncooked_hotdog'] 			= {['name'] = 'uncooked_hotdog', 		        ['label'] = 'Raw HotDog', 	        ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'uncooked_hotdog.png',     	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['ribs'] 			            = {['name'] = 'ribs', 		        	   	    ['label'] = 'Spare Ribs', 		    ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'ribs.png', 	          	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['uncooked_ribs'] 	     		= {['name'] = 'uncooked_ribs', 		           	['label'] = 'Raw Ribs', 	        ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'uncooked_ribs.png',     	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['brisket'] 			        = {['name'] = 'brisket', 		           	    ['label'] = 'Brisket Joint', 	    ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'brisket.png', 	        	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['uncooked_brisket'] 			= {['name'] = 'uncooked_brisket', 		        ['label'] = 'Raw Brisket', 	        ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'uncooked_brisket.png',    	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['jacket_potato'] 			    = {['name'] = 'jacket_potato', 		        	['label'] = 'Loaded Jacket', 	    ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'jacket_potato.png', 	   	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['uncooked_jacket'] 			= {['name'] = 'uncooked_jacket', 		        ['label'] = 'Raw Jacket', 	        ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'uncooked_jacket.png',    	['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['bread'] 			            = {['name'] = 'bread', 		        	   	    ['label'] = 'Bread', 		        ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'bread.png', 	            ['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['cheese'] 			            = {['name'] = 'cheese', 		        	   	['label'] = 'Cheese', 		        ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'cheese.png', 	            ['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    
    -- BBQS
    ['bbq1'] 			 	    	 = {['name'] = 'bbq1', 					    	['label'] = 'Forge Djorman', 		['weight'] = 500, 		['type'] = 'item', 		['image'] = 'bbq1.png', 		    		['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
	['bbq2'] 			 			 = {['name'] = 'bbq2', 					    	['label'] = 'Leetle Grill', 		['weight'] = 500, 		['type'] = 'item', 		['image'] = 'bbq2.png', 		    		['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
	['bbq3'] 			 			 = {['name'] = 'bbq3', 					    	['label'] = 'Stand Grill', 			['weight'] = 500, 		['type'] = 'item', 		['image'] = 'bbq3.png', 		    		['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
	['bbq4'] 			 			 = {['name'] = 'bbq4', 				    		['label'] = 'Craftguy Grill', 		['weight'] = 500, 		['type'] = 'item', 		['image'] = 'bbq4.png', 		    		['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
	['bbq5'] 			 			 = {['name'] = 'bbq5', 				    		['label'] = 'Brick-Lain Grill', 	['weight'] = 500, 		['type'] = 'item', 		['image'] = 'bbq5.png', 		    		['unique'] = true, 		['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},   
    
    --FUEL
    ['wood'] 			             = {['name'] = 'wood', 		        	   	['label'] = 'Wood', 		        ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'wood.png', 	        	    ['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['coal'] 			             = {['name'] = 'coal', 		        	   	['label'] = 'Coal', 		        ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'coal.png', 	        	    ['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    ['propane'] 			         = {['name'] = 'propane', 		        	['label'] = 'Propane', 		        ['weight'] = 500, 		['type'] = 'item', 		['image'] = 'propane.png', 	        	    ['unique'] = false, 	['useable'] = true, 	['shouldClose'] = true,	   ['combinable'] = nil,   ['description'] = ''},
    
}

```

## Insert Contents of @sayer-bbq/Images into your inventory image folder

