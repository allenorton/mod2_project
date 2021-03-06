class Recipe < ApplicationRecord
    belongs_to :style
    has_many :recipes_users
    has_many :users, through: :recipes_users
    has_many :favorites
    has_many :items
    has_many :ingredients, through: :items
    accepts_nested_attributes_for :ingredients, :allow_destroy => true
    
    validates :name, presence: true
    validates :name, uniqueness: { case_sensitive: true }
    validates :style, presence: { case_sensitive: true }
    validates :prep_time, presence:true
    #validates :rating, numericality: { only_integer: true }
    #validates_numericality_of :rating, less_than_or_equal_to: 10
    before_validation :uppercase_name
    # validates :prep_time, inclusion: {in: %w( min ), message: "Prep time must be in specified in minutes (min)" }
    validates :description, length: {minimum: 20}
    validates_associated :ingredients

    def ingredients_attributes=(ingredient_attributes)
        ingredient_attributes.values.each do |ingredient_attribute|
            if ingredient_attribute[:_destroy] == '1'
                ing = Ingredient.find_or_create_by(name: ingredient_attribute['name'], category: ingredient_attribute['category'])
                ing.delete
              else
                ing = Ingredient.find_or_create_by(name: ingredient_attribute['name'], category: ingredient_attribute['category'])
                self.ingredients << ing unless self.ingredients.include?(ing)
              end
            ingredient_attribute[:items_attributes].values.each do |item_attribute|
                #byebug
                if self.items.any?
                    self.items.each {|item| item.recipe_id == self.id && item.ingredient_id == ing.id}
                    item = self.items.select {|i| i.ingredient_id == ing.id && i.recipe_id == self.id}
                    nu_item = item.first
                    nu_item.quantity = item_attribute unless item_attribute.blank?
                    nu_item.save
                else
                    item = self.items.select {|i| i.ingredient_id == ing.id }
                    nu_item = item.first 
                    nu_item.quantity = item_attribute unless item_attribute.blank?
                    nu_item.save
                end
            end
        end
    end
    

    def uppercase_name
      name.upcase!
    end

    def self.average_calories
        cal =   self.all.collect do |recipe|
                    recipe.calories
                end
                
        tc = cal.sum 
        tr = Recipe.all.count
        ans = (tc / tr)
        ans
    end

    def self.average_rating
        rat = self.all.collect do |recipe|
                recipe.rating
              end
        
        ar = rat.sum 
        tr = Recipe.all.count
        ans = (ar / tr)
        ans
    end

    def self.average_prep_time
        prep = self.all.collect do |recipe|
                    recipe.prep_time.split('min')
                end
                #prep looks like: [["35 "], ["90 "], ["40 "]] 
        prep = prep.join.split
               #now prep looks like: ["35", "90", "40"] 

        prep.sum { |n| n.to_i } # turns each number to string then adds them together 
    end

    def self.all_recipes
        self.all.count 
    end


    def self.all_vegan_dishes
        self.all.collect do |dish|
            if dish.style_id == 35 #Style.where(name: 'VEGAN').id
                dish.name
            end
            
        end.compact
    end

    def self.all_vegetarian_dishes
        self.all.collect do |dish|
            if dish.style_id == 36
                dish.name
            end
            
        end.compact
    end

    def total_number_of_users
        User.all.count
    end


    def most_favorited_style
    end

end

