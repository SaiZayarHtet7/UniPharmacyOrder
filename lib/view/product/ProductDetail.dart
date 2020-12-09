import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:uni_pharmacy_order/service/firestore_service.dart';
import 'package:uni_pharmacy_order/util/constants.dart';
import 'package:uni_pharmacy_order/view/product/ProductOrder.dart';
import 'package:uni_pharmacy_order/widget/PriceCard.dart';
import 'package:uni_pharmacy_order/widget/TitleText.dart';
import 'package:uni_pharmacy_order/widget/TitleTextColor.dart';


final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class ProductDetail extends StatefulWidget {

  final String productName,productImage,productId,productDescription;
 const ProductDetail( this.productName, this.productImage, this.productId, this.productDescription);

  @override
  _ProductDetailState createState() => _ProductDetailState(productId,productName,productDescription,productImage);
}

class _ProductDetailState extends State<ProductDetail> {

  String productName,productImage,productId,productDescription,category;
  bool loading;
  _ProductDetailState(this.productId, this.productName, this.productDescription, this.productImage);
  List<String> specialPriceList = [];
  String count;


  @override
  void initState() {
    // TODO: implement initState
    fetchData();
    setState(() {
      Firebase.initializeApp();
    });
    super.initState();
  }
  fetchData() async {
    FirebaseFirestore.instance.collection("product").doc(productId).collection("price").where("price_kind",isEqualTo: "အထူးစျေး").get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        setState(() {
          specialPriceList.add(result.data()['price_id'].toString());
          print(specialPriceList);
          count=specialPriceList.length.toString();
          print(count);
        });

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(backgroundColor: Constants.thirdColor,
        toolbarHeight: 70,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.white,), onPressed: (){
          Navigator.of(context).pop();
        }),
        title:
        Container(
          padding: EdgeInsets.only(right: 10.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(productName,style: TextStyle(fontFamily: Constants.PrimaryFont),)
                ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(top: 10,bottom: 70,left: 10,right: 10),
              width: MediaQuery.of(context).size.width,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                loading==true?Center(
                  child: Container(width: 120.0,
                      height: 120.0,
                      child: CircularProgressIndicator(backgroundColor: Constants.primaryColor,)),
                ) :InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LargeImage(productImage)),
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1,color: Constants.thirdColor
                      ),
                      shape: BoxShape.circle,
                    ),
                    child:Center(
                      child: CachedNetworkImage(
                        imageUrl: productImage,
                        fit: BoxFit.cover,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 120.0,
                          height: 120.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0,),
                Container(width: double.infinity,
                    child: TitleTextColor("Description",Constants.primaryColor)),
                SizedBox(height: 10.0,),
                Container(
                  width: double.infinity,
                  child: Text(
                    productDescription,style: TextStyle(fontFamily: Constants.PrimaryFont,fontSize: 16,height: 2),
                  ),
                ),
                SizedBox(height: 10.0,),
                Divider(color: Colors.grey,thickness: 2,),
                SizedBox(height: 15.0,),
                Container(width: double.infinity,
                    child: Text("လက်လီစျေး",style:TextStyle(color: Constants.primaryColor,fontFamily: Constants.PrimaryFont,fontSize: 16) ,)
                   ),
                Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('product').doc(productId).collection("price").where("price_kind",isEqualTo: "လက်လီစျေး").snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if(snapshot.hasData){
                            return Container(
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: snapshot.data.documents.map((DocumentSnapshot document)
                                {
                                  // return PriceCard(document.data()['price_kind'], document.data()['quantity'], document.data()['unit'], document.data()['price']);
                                  return PriceCard(document.data()["quantity"].toString(), document.data()['unit'], document.data()['price']);
                                }).toList(),
                              ),
                            );
                          }else{
                            return TitleTextColor("No data", Constants.thirdColor);
                          }
                        }),
                  ),
                ),
                SizedBox(height: 10,),
                Container(width: double.infinity,
                    child: Text("လက်ကားစျေး",style:TextStyle(color: Constants.primaryColor,fontFamily: Constants.PrimaryFont,fontSize: 16) ,)
                ),
                Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('product').doc(productId).collection("price").where("price_kind",isEqualTo: "လက်ကားစျေး").snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          return Container(
                            child: ListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: snapshot.data.documents.map((DocumentSnapshot document)
                              {
                                // return PriceCard(document.data()['price_kind'], document.data()['quantity'], document.data()['unit'], document.data()['price']);
                                return PriceCard(document.data()["quantity"].toString(), document.data()['unit'], document.data()['price']);
                              }).toList(),
                            ),
                          );
                        }),
                  ),
                ),
                SizedBox(height: 10.0,),
                count=="0" || count==null?SizedBox(): Container(width: double.infinity,
                    child: Text("အထူးစျေး",style:TextStyle(color: Constants.primaryColor,fontFamily: Constants.PrimaryFont,fontSize: 16) ,)
                ),
                count=="0" || count==null?SizedBox(): Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('product').doc(productId).collection("price").where("price_kind",isEqualTo: "အထူးစျေး").snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          return Container(
                            child: ListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: snapshot.data.documents.map((DocumentSnapshot document)
                              {
                                // return PriceCard(document.data()['price_kind'], document.data()['quantity'], document.data()['unit'], document.data()['price']);
                                return PriceCard(document.data()["quantity"].toString(), document.data()['unit'], document.data()['price']);
                              }).toList(),
                            ),
                          );
                        }),
                  ),
                ),
                count=="0" || count==null?SizedBox(): SizedBox(height: 10.0,),
              ],
            ),),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(10),
              height: 50.0,
              child: RaisedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductOrder("","","",productId,productName,productImage,"","","","")),
                  );
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0),),
                padding: EdgeInsets.all(0.0),
                child: Ink(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Hexcolor('#fd9346'),Constants.primaryColor,Hexcolor('#fd9346'),],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30.0)
                  ),
                  child: Container(
                    constraints: BoxConstraints(minHeight: 50.0),
                    alignment: Alignment.center,
                    child: Text('ဝယ်မည်',style: TextStyle(color: Colors.white,fontSize: 18.0,fontFamily:Constants.PrimaryFont),),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LargeImage extends StatelessWidget {
  String imgUrl;
  LargeImage(this.imgUrl);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child:InkWell(
        onTap: (){
          Navigator.of(context).pop();
        },
        child: Center(
          child: CachedNetworkImage(
            imageUrl: imgUrl,
            fit: BoxFit.cover,
            imageBuilder: (context, imageProvider) => Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: imageProvider, fit: BoxFit.fitWidth),
              ),
            ),
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),),
    );
  }
}
