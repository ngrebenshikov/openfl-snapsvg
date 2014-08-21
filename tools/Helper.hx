package tools;
class Helper {
    public static function getAnchorIdFromUrl(url: String): String {
        var ereg = ~/url[(](.+)[)]/;
        var id = if (ereg.match(url)) ereg.matched(1) else url;
        if (id.indexOf(String.fromCharCode(34)) != -1) {
            id = id.substr(1,id.length-2);
        }
        if (id.indexOf(String.fromCharCode(39)) != -1) {
            id = id.substr(1,id.length-2);
        }
        if (null == id) return null;
        if (id.indexOf('#') != -1) {
            id = id.substring(id.indexOf('#')+1, id.length);
        }
        return id;
    }
}
