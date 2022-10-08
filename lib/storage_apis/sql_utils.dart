String getSqlString(String? dartString) {
  if (dartString is! String) {
    return "";
  }
  return "'$dartString'";
}
