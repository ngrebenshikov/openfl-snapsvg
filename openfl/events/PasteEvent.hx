package openfl.events;

class PasteEvent extends Event {
    public var text: String;
    public function new(text: String) {
        super(Event.PASTE);
        this.text = text;
    }
}
