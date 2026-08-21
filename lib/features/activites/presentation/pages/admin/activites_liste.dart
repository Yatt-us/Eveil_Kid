import 'package:eveilkid/core/constants/AppSpacing.dart';
import 'package:eveilkid/core/constants/AppTextStyles.dart';
import 'package:eveilkid/core/constants/app_colors.dart';
import 'package:eveilkid/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eveilkid/shared/widgets/app_search_bar.dart';


import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActivitesListe extends StatelessWidget {
  const ActivitesListe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(
        currentRoute: AdminNavRoute.activites
      ),
      appBar: AppBar(
        
        centerTitle: true,
        title: Text("Activité", style: AppTextStyles.headingMedium,),
        iconTheme: const IconThemeData(
      color: AppColors.primary,
    ),
        actions: [
          IconButton(onPressed: (){}, icon:Icon(Icons.notifications) )
        ],
        
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.only(top: 10),
        child: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              
              children: [
                Expanded(
                  child: AppSearchBar(),
                ),
                AppSpacing.horizontalXl,
                Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(2),
                  
                  decoration: BoxDecoration(
                    borderRadius:BorderRadius.circular(15),
                    color: AppColors.primary, ),
                  child: IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/filter.svg", colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn,),),
                ),
                )
                
              ],
            ),
          ),
          SizedBox(height: 15,),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20,),
            child: SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
         
        ),
        child: const Text("Tous"),
      ),

      const SizedBox(width: 8),

      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 236, 236, 236),
          foregroundColor: const Color.fromARGB(255, 74, 73, 73),
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          
        ),
        child: const Text("Cognitive"),
      ),

      const SizedBox(width: 8),

      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 236, 236, 236),
          foregroundColor: const Color.fromARGB(255, 74, 73, 73),
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          
        ),
        child: const Text("Logic"),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 236, 236, 236),
          foregroundColor: const Color.fromARGB(255, 74, 73, 73),
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          
        ),
        child: const Text("Art"),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 236, 236, 236),
          foregroundColor: const Color.fromARGB(255, 74, 73, 73),
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          
        ),
        child: const Text("Informatics"),
      ),
    ],
  ),
) ,),
Padding(
  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
  
    child:  Column(
      
      
      children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            width: 400,
            height: 100,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
          ),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            width: 400,
            height: 100,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
          ),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            width: 400,
            height: 100,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
          ),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            width: 400,
            height: 100,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
          ),
         
         
      ]
      ,
    ),
    )
  
    
  
          
        


  ],
),),
       


      
      
      
    );
  }
}