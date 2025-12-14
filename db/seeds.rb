MenuItem.destroy_all
Menu.destroy_all

puts "Seeding Menus and MenuItems..."

menus = [
  {
    name: "Breakfast Menu",
    description: "Start your day with our healthy and delicious breakfast options.",
    active: true,
    categories: [ "Breakfast" ]
  },
  {
    name: "Lunch Menu",
    description: "Our lunch specials include vegan, vegetarian, and meat options.",
    active: true,
    categories: [ "Lunch" ]
  },
  {
    name: "Dinner Menu",
    description: "Delicious dinner items to enjoy with friends and family.",
    active: false,
    categories: [ "Dinner" ]
  }
]

menus.each do |menu_attrs|
  menu = Menu.create!(menu_attrs)

  if menu.name == "Breakfast Menu"
    menu.menu_items.create!([
      {
        name: "Vegan Pancakes",
        description: "Fluffy pancakes made with oat milk, served with maple syrup.",
        price: 12.50,
        spicy: false,
        vegan: true,
        vegetarian: true,
        categories: [ "Breakfast", "Vegan" ]
      },
      {
        name: "Egg & Cheese Sandwich",
        description: "Classic breakfast sandwich with scrambled eggs and cheese.",
        price: 10.00,
        spicy: false,
        vegan: false,
        vegetarian: true,
        categories: [ "Breakfast" ]
      }
    ])
  elsif menu.name == "Lunch Menu"
    menu.menu_items.create!([
      {
        name: "Grilled Chicken Salad",
        description: "Fresh greens with grilled chicken, avocado, and vinaigrette.",
        price: 15.00,
        spicy: false,
        vegan: false,
        vegetarian: false,
        categories: [ "Lunch" ]
      },
      {
        name: "Spicy Vegan Curry",
        description: "A hearty curry with chickpeas, coconut milk, and chili.",
        price: 13.50,
        spicy: true,
        vegan: true,
        vegetarian: true,
        categories: [ "Lunch", "Vegan", "Spicy" ]
      }
    ])
  elsif menu.name == "Dinner Menu"
    menu.menu_items.create!([
      {
        name: "Vegetarian Lasagna",
        description: "Layers of pasta, vegetables, and cheese baked to perfection.",
        price: 18.00,
        spicy: false,
        vegan: false,
        vegetarian: true,
        categories: [ "Dinner", "Vegetarian" ]
      },
      {
        name: "Vegan Buddha Bowl",
        description: "Quinoa, roasted vegetables, chickpeas, and tahini dressing.",
        price: 16.00,
        spicy: false,
        vegan: true,
        vegetarian: true,
        categories: [ "Dinner", "Vegan" ]
      }
    ])
  end
end

puts "Seeding complete!"
