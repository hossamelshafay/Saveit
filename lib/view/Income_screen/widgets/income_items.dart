import 'package:flutter/material.dart';

class incomeitems extends StatelessWidget {
  final String tit;
  final String subtit;
  final double amount;
  final IconData icon;
  const incomeitems({
    super.key,
    required this.tit,
    required this.subtit,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(vertical: 8,horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          leading: Icon(icon,size: 36,),
          title: Text(tit,style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text(subtit,style: TextStyle(color: Colors.grey),),
          trailing: Text('\$${amount.toStringAsFixed(0)}',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
        ),
    );
  }
}
