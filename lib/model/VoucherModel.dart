class VoucherModel {
  final int voucherNumber;
  final String voucherId;
  final String userId;
  final String userName;
  final String dateTime;
  final String status;
  final String token;
  final List<String> searchName;


  VoucherModel(
      { this.voucherNumber,
        this.voucherId,
        this.userId ,
        this.userName,
        this.dateTime,
        this.status,
        this.token,
        this.searchName,
      });

  Map<String, dynamic> toMap() {
    return {
      'voucher_number': voucherNumber,
      'voucher_id': voucherId,
      'user_id': userId,
      'user_name': userName,
      'date_time': dateTime,
      'status': status,
      'token':token,
      'search_name':searchName
    };
  }
}
