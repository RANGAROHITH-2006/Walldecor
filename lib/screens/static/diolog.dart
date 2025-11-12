import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Future<void> showAddFloorDialog({
  required BuildContext context,
  required Function(String) onCreate,
}) async {
  final controller = TextEditingController();

  await showDialog(
    context: context,
    // barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF40424E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create New Library',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.white54, thickness: 1),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF50525C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter library name',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(105, 38),
                    backgroundColor: const Color(0xFFEE5776),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.5),
                    ),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    final libraryName = controller.text.trim();
                    if (libraryName.isNotEmpty) {
                      onCreate(libraryName);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}




Future<void> EditlibraryDialog({
  required BuildContext context,
  required Function(String) onCreate,
}) async {
  final controller = TextEditingController();

  await showDialog(
    context: context,
    // barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: const Color(0xFF40424E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rename Library Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.white54, thickness: 1),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF50525C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter new library name',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(105, 38),
                    backgroundColor: const Color(0xFFEE5776),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.5),
                    ),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    final libraryName = controller.text.trim();
                    if (libraryName.isNotEmpty) {
                      onCreate(libraryName);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}



class SaveLibrarySheet extends StatelessWidget {
  const SaveLibrarySheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      
      padding: const EdgeInsets.all(16.0),
      child: Column(
        
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(' '),
               const Text(
                  'Save to Library',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                ),
              IconButton(
                icon: const Icon(Icons.close,color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          const _LibraryItem(name: 'Allover Homestyle'),
          const _LibraryItem(name: 'Dreams Creative'),
          const _LibraryItem(name: 'Ruff Shed'),
          const _LibraryItem(name: 'Mermaid Graphics'),
          const SizedBox(height: 10),
          ListTile(
            leading: SvgPicture.asset('assets/svg/library.svg',width: 24,height: 24,color: Colors.white,),
            title: const Text('Create new library',style: TextStyle(color: Colors.white),),
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _LibraryItem extends StatelessWidget {
  final String name;
  const _LibraryItem({required this.name});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset('assets/collection/collection3.png', width: 30, height: 48 , fit: BoxFit.cover,),
      title: Text(name,style: TextStyle(color: Colors.white),),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name selected',style: TextStyle(color: Colors.white),)),
        );
      },
    );
  }
}