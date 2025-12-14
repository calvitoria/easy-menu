MenuItem.destroy_all
Menu.destroy_all
Restaurant.destroy_all

puts "Seeding Restaurants, Menus, and MenuItems..."

# Create Restaurants
restaurants = [
  {
    name: "Green Leaf Café",
    email: "hello@greenleafcafe.com",
    description: "A cozy café specializing in healthy, plant-based options.",
    address: "123 Organic Lane, Health City, HC 12345"
  },
  {
    name: "Spice & Soul Bistro",
    email: "info@spicesoulbistro.com",
    description: "Modern bistro with global flavors and soulful dishes.",
    address: "456 Flavor Avenue, Culinary Town, CT 67890"
  },
  {
    name: "Urban Kitchen",
    email: "contact@urbankitchen.com",
    description: "Contemporary dining with locally-sourced ingredients.",
    address: "789 Downtown Street, Metro City, MC 11223"
  },
  {
    name: "Sunrise Diner",
    email: "sunrise@sunrisediner.com",
    description: "Classic American diner with all-day breakfast.",
    address: "101 Morning Road, Sunrise City, SC 44556"
  }
]

restaurants.each do |restaurant_attrs|
  restaurant = Restaurant.create!(restaurant_attrs)
  puts "Created restaurant: #{restaurant.name}"
end

puts "\nCreating menus for each restaurant..."

# Restaurant 1: Green Leaf Café
green_leaf = Restaurant.find_by(name: "Green Leaf Café")
green_leaf_menus = [
  {
    name: "Breakfast Menu",
    description: "Start your day with our healthy and delicious breakfast options.",
    active: true,
    categories: [ "Breakfast", "Healthy" ]
  },
  {
    name: "Lunch Menu",
    description: "Our lunch specials include vegan, vegetarian, and meat options.",
    active: true,
    categories: [ "Lunch", "Seasonal" ]
  },
  {
    name: "Evening Specials",
    description: "Light bites and drinks for the evening.",
    active: true,
    categories: [ "Evening", "Drinks" ]
  }
]

green_leaf_menus.each do |menu_attrs|
  menu = green_leaf.menus.create!(menu_attrs)
  puts "  Created menu: #{menu.name} for #{green_leaf.name}"

  # Add menu items based on menu type
  case menu.name
  when "Breakfast Menu"
    menu.menu_items.create!([
      {
        name: "Vegan Pancakes",
        description: "Fluffy pancakes made with oat milk, served with maple syrup.",
        price: 12.50,
        spicy: false,
        vegan: true,
        vegetarian: true,
        categories: [ "Breakfast", "Vegan", "Signature" ]
      },
      {
        name: "Avocado Toast",
        description: "Sourdough toast with smashed avocado, cherry tomatoes, and herbs.",
        price: 11.00,
        spicy: false,
        vegan: true,
        vegetarian: true,
        categories: [ "Breakfast", "Vegan", "Popular" ]
      },
      {
        name: "Green Smoothie Bowl",
        description: "Blended greens, banana, and almond milk topped with granola and berries.",
        price: 10.50,
        spicy: false,
        vegan: true,
        vegetarian: true,
        categories: [ "Breakfast", "Vegan", "Healthy" ]
      }
    ])
  when "Lunch Menu"
    menu.menu_items.create!([
      {
        name: "Spicy Vegan Curry",
        description: "A hearty curry with chickpeas, coconut milk, and chili.",
        price: 13.50,
        spicy: true,
        vegan: true,
        vegetarian: true,
        categories: [ "Lunch", "Vegan", "Spicy", "Signature" ]
      },
      {
        name: "Quinoa Salad Bowl",
        description: "Mixed greens, quinoa, roasted vegetables, and lemon tahini dressing.",
        price: 12.00,
        spicy: false,
        vegan: true,
        vegetarian: true,
        categories: [ "Lunch", "Vegan", "Healthy" ]
      },
      {
        name: "Grilled Vegetable Wrap",
        description: "Seasonal vegetables wrapped in a whole wheat tortilla with hummus.",
        price: 10.50,
        spicy: false,
        vegan: true,
        vegetarian: true,
        categories: [ "Lunch", "Vegan", "Quick" ]
      }
    ])
  when "Evening Specials"
    menu.menu_items.create!([
      {
        name: "Hummus Platter",
        description: "Fresh hummus with pita bread, olives, and vegetables.",
        price: 9.50,
        spicy: false,
        vegan: true,
        vegetarian: true,
        categories: [ "Appetizer", "Vegan", "Shareable" ]
      },
      {
        name: "Herbal Tea Selection",
        description: "Choose from our assortment of organic herbal teas.",
        price: 4.50,
        spicy: false,
        vegan: true,
        vegetarian: true,
        categories: [ "Drink", "Hot" ]
      }
    ])
  end
end

# Restaurant 2: Spice & Soul Bistro
spice_soul = Restaurant.find_by(name: "Spice & Soul Bistro")
spice_soul_menus = [
  {
    name: "Dinner Menu",
    description: "Delicious dinner items to enjoy with friends and family.",
    active: true,
    categories: [ "Dinner", "Main" ]
  },
  {
    name: "Weekend Brunch",
    description: "Special weekend brunch with global influences.",
    active: false, # Inactive menu
    categories: [ "Brunch", "Weekend" ]
  }
]

spice_soul_menus.each do |menu_attrs|
  menu = spice_soul.menus.create!(menu_attrs)
  puts "  Created menu: #{menu.name} for #{spice_soul.name}"

  case menu.name
  when "Dinner Menu"
    menu.menu_items.create!([
      {
        name: "Vegetarian Lasagna",
        description: "Layers of pasta, vegetables, and cheese baked to perfection.",
        price: 18.00,
        spicy: false,
        vegan: false,
        vegetarian: true,
        categories: [ "Dinner", "Vegetarian", "Italian" ]
      },
      {
        name: "Spicy Thai Noodles",
        description: "Rice noodles with vegetables in a spicy coconut curry sauce.",
        price: 16.50,
        spicy: true,
        vegan: true,
        vegetarian: true,
        categories: [ "Dinner", "Vegan", "Thai", "Spicy" ]
      },
      {
        name: "Herb-Crusted Salmon",
        description: "Atlantic salmon with herb crust, served with seasonal vegetables.",
        price: 22.00,
        spicy: false,
        vegan: false,
        vegetarian: false,
        categories: [ "Dinner", "Seafood", "Signature" ]
      }
    ])
  when "Weekend Brunch"
    menu.menu_items.create!([
      {
        name: "Shakshuka",
        description: "Eggs poached in a spicy tomato and pepper sauce.",
        price: 14.00,
        spicy: true,
        vegan: false,
        vegetarian: true,
        categories: [ "Brunch", "Middle Eastern", "Spicy" ]
      },
      {
        name: "French Toast",
        description: "Brioche french toast with berries and maple syrup.",
        price: 12.50,
        spicy: false,
        vegan: false,
        vegetarian: true,
        categories: [ "Brunch", "Sweet" ]
      }
    ])
  end
end

# Restaurant 3: Urban Kitchen
urban_kitchen = Restaurant.find_by(name: "Urban Kitchen")
urban_kitchen_menus = [
  {
    name: "Lunch Specials",
    description: "Quick and delicious lunch options for busy urbanites.",
    active: true,
    categories: [ "Lunch", "Quick" ]
  },
  {
    name: "Dinner Tasting Menu",
    description: "Chef's selection of small plates for a complete dining experience.",
    active: true,
    categories: [ "Dinner", "Tasting", "Premium" ]
  }
]

urban_kitchen_menus.each do |menu_attrs|
  menu = urban_kitchen.menus.create!(menu_attrs)
  puts "  Created menu: #{menu.name} for #{urban_kitchen.name}"

  case menu.name
  when "Lunch Specials"
    menu.menu_items.create!([
      {
        name: "Grilled Chicken Salad",
        description: "Fresh greens with grilled chicken, avocado, and vinaigrette.",
        price: 15.00,
        spicy: false,
        vegan: false,
        vegetarian: false,
        categories: [ "Lunch", "Salad", "Protein" ]
      },
      {
        name: "Urban Burger",
        description: "Grass-fed beef burger with house sauce and crispy fries.",
        price: 16.50,
        spicy: false,
        vegan: false,
        vegetarian: false,
        categories: [ "Lunch", "Burger", "Popular" ]
      },
      {
        name: "Market Vegetable Soup",
        description: "Seasonal vegetable soup with crusty bread.",
        price: 8.50,
        spicy: false,
        vegan: true,
        vegetarian: true,
        categories: [ "Lunch", "Soup", "Vegan" ]
      }
    ])
  when "Dinner Tasting Menu"
    menu.menu_items.create!([
      {
        name: "Truffle Arancini",
        description: "Crispy risotto balls with black truffle and mozzarella.",
        price: 12.00,
        spicy: false,
        vegan: false,
        vegetarian: true,
        categories: [ "Appetizer", "Italian", "Premium" ]
      },
      {
        name: "Pan-Seared Scallops",
        description: "Scallops with cauliflower puree and crispy pancetta.",
        price: 24.00,
        spicy: false,
        vegan: false,
        vegetarian: false,
        categories: [ "Seafood", "Premium", "Signature" ]
      },
      {
        name: "Chocolate Lava Cake",
        description: "Warm chocolate cake with molten center and vanilla ice cream.",
        price: 9.50,
        spicy: false,
        vegan: false,
        vegetarian: true,
        categories: [ "Dessert", "Chocolate" ]
      }
    ])
  end
end

# Restaurant 4: Sunrise Diner
sunrise_diner = Restaurant.find_by(name: "Sunrise Diner")
sunrise_diner_menus = [
  {
    name: "All-Day Breakfast",
    description: "Classic breakfast favorites served any time of day.",
    active: true,
    categories: [ "Breakfast", "Classic" ]
  },
  {
    name: "Comfort Food Classics",
    description: "Hearty dishes that feel like home.",
    active: true,
    categories: [ "Comfort", "American" ]
  }
]

sunrise_diner_menus.each do |menu_attrs|
  menu = sunrise_diner.menus.create!(menu_attrs)
  puts "  Created menu: #{menu.name} for #{sunrise_diner.name}"

  case menu.name
  when "All-Day Breakfast"
    menu.menu_items.create!([
      {
        name: "Egg & Cheese Sandwich",
        description: "Classic breakfast sandwich with scrambled eggs and cheese.",
        price: 10.00,
        spicy: false,
        vegan: false,
        vegetarian: true,
        categories: [ "Breakfast", "Sandwich", "Classic" ]
      },
      {
        name: "Pancake Stack",
        description: "Three fluffy pancakes with butter and maple syrup.",
        price: 9.50,
        spicy: false,
        vegan: false,
        vegetarian: true,
        categories: [ "Breakfast", "Sweet", "Classic" ]
      },
      {
        name: "Breakfast Burrito",
        description: "Scrambled eggs, cheese, potatoes, and salsa in a tortilla.",
        price: 11.50,
        spicy: true,
        vegan: false,
        vegetarian: true,
        categories: [ "Breakfast", "Mexican", "Spicy" ]
      }
    ])
  when "Comfort Food Classics"
    menu.menu_items.create!([
      {
        name: "Mac & Cheese",
        description: "Creamy macaroni and cheese with a crispy breadcrumb topping.",
        price: 12.00,
        spicy: false,
        vegan: false,
        vegetarian: true,
        categories: [ "Comfort", "Pasta", "Vegetarian" ]
      },
      {
        name: "Chicken Pot Pie",
        description: "Flaky pastry filled with chicken and vegetables in creamy sauce.",
        price: 14.50,
        spicy: false,
        vegan: false,
        vegetarian: false,
        categories: [ "Comfort", "Pie", "Classic" ]
      },
      {
        name: "Apple Pie",
        description: "Homemade apple pie with cinnamon and a scoop of ice cream.",
        price: 7.50,
        spicy: false,
        vegan: false,
        vegetarian: true,
        categories: [ "Dessert", "Pie", "Classic" ]
      }
    ])
  end
end

puts "\nSeeding complete!"
puts "======================================"
puts "Created:"
puts "  #{Restaurant.count} restaurants"
puts "  #{Menu.count} menus"
puts "  #{MenuItem.count} menu items"
puts "======================================"
puts "\nSample data:"
Restaurant.all.each do |restaurant|
  puts "\n#{restaurant.name}:"
  puts "  Email: #{restaurant.email}"
  puts "  Menus: #{restaurant.menus.count}"
  puts "  Menu Items: #{restaurant.menu_items.count}"
  restaurant.menus.each do |menu|
    puts "    - #{menu.name} (#{menu.active ? 'Active' : 'Inactive'}): #{menu.menu_items.count} items"
  end
end
