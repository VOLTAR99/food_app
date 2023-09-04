import 'package:flutter/material.dart';
import 'package:food_app/data/dummy_data.dart';
import 'package:food_app/screens/categories.dart';
import 'package:food_app/screens/filters.dart';
import 'package:food_app/screens/meals.dart';
import 'package:food_app/models/meal.dart';
import 'package:food_app/widgets/main_drawer.dart';

const KInitialFilters = {
  Filter.glutenFree:false,
  Filter.lactoseFree:false,
  Filter.vegetarian:false,
  Filter.vegan:false,
};

class TabsScreen extends StatefulWidget{
   const TabsScreen ({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen>{
  int _selectedPageIndex = 0;
  final List<Meal> _favouriteMeals = [];
  Map<Filter, bool> _selectedFilters = KInitialFilters ;
  
  void _showInfoMessage(String message){
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
        ),
    );
  }

  void _toggleMealFavouriteStatus(Meal meal){
    final isExisting = _favouriteMeals.contains(meal);

    if(isExisting){
      setState(() {
        _favouriteMeals.remove(meal);
      });
     _showInfoMessage('Meal is no longer Favourites');
    }else{
      setState(() {
        _favouriteMeals.add(meal);
      });
      _showInfoMessage('Meal marked as Favourite');
    }
  }

  void _selectPage(int index){
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _setScreen(String identifier)async{
    Navigator.of(context).pop();
      if(identifier == 'filters'){
        final result = await Navigator.of(context).push<Map<Filter, bool>>(
             MaterialPageRoute(
                 builder: (ctx) => FilterScreen(currentFilters: _selectedFilters,),
             ),
         );
        setState(() {
          _selectedFilters = result ?? KInitialFilters;
        });

      }
  }


  @override
  Widget build(BuildContext context) {
     final availableMeals = dummyMeals.where((meal) {
       if(_selectedFilters[Filter.glutenFree]! && !meal.isGlutenFree){
         return false;
       }
       if(_selectedFilters[Filter.lactoseFree]! && !meal.isLactoseFree){
         return false;
       }
       if(_selectedFilters[Filter.vegetarian]! && !meal.isVegetarian){
         return false;
       }
       if(_selectedFilters[Filter.vegan]! && !meal.isVegan){
         return false;
       }
       return true;
     }).toList();

    Widget activePage = CategoriesScreen(
      onToggleFavourite: _toggleMealFavouriteStatus,
    availableMeals: availableMeals,);
    var activePageTitle = 'Categories';

    if(_selectedPageIndex==1){
      activePage = MealsScreen(
        meals: _favouriteMeals,
        onToggleFavourite: _toggleMealFavouriteStatus,);
      activePageTitle = 'Your Favourites';
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      drawer: MainDrawer(onSelectScreen: _setScreen,),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.set_meal), label: 'Categories' ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites' ),
        ],
      ),
    );
  }
}