#include <Bass.au3>
#include <BassConstants.au3>
#include <BassTags.au3>

;Open Bass.DLL.  Required for all function calls.
_BASS_STARTUP("BASS.dll")
_Bass_Tags_Startup("BassTags.dll")

;Initalize bass.  Required for most functions.
_BASS_Init(0, -1, 44100, 0, "")

$file = FileOpenDialog("Open...", "", "MP3 Files (*.mp3)")
;Create a stream from that file.
$MusicHandle = _BASS_StreamCreateFile(False, $file, 0, 0, $BASS_MUSIC_PRESCAN)
;Check if we opened the file correctly.
If @error Then
    MsgBox(0, "Error", "Could not load audio file" & @CR & "Error = " & @error)
    Exit
EndIf

#cs format string can contain the following things:
       - plain text like "Some song". This text is merely copied to the output.
       - special identifier, beginning with '%' to substitute for the tag value:
         "%TITL"  - song title;
         "%ARTI"  - song artist;
         "%ALBM"  - album name;
         "%GNRE"  - song genre;
         "%YEAR"  - song/album year;
         "%CMNT"  - comment;
         "%TRCK"  - track number;
         "%COMP"  - composer;
         "%COPY"  - copyright;
         "%SUBT"  - subtitle;
         "%AART"  - album artist;
       - expression:
         "%IFV1(x,a)" - if x is not empty, then %IFV1() evaluates to a,
                        or to an empty string otherwise;
         "%IFV2(x,a,b)" - if x is not empty, then %IFV2() evaluates to a,
                        else to b;
         "%IUPC(x)" - brings x to uppercase, so "%IUPC(foO)" yields "FOO";
         "%ILWC(x)" - brings x to lowercase, so "%ILWC(fOO)" yields "foo";
         "%ICAP(x)" - capitalizes first letter in each word of x, so
                      "%ICAP(FoO bAR)" yields "Foo Bar";
         "%ITRM(x)" - removes beginning and trailing spaces from x;
         "%UTF8(x)" - encodes the tags in UTF-8 form (otherwise ANSI);

       - escaped symbols:
         "%%" - "%"
         "%(" - "("
         "%," - ","
         "%)" - ")"

       Example. Assume we have the following information in the tag:
	     Title: "Nemo"
	     Artist: "nightwish"
	     Album: "Once"
	     Track: "3"
	     Year: "2004"

         Format string: "%IFV1(%TRCK,%TRCK. )%IFV2(%ARTI,%ICAP(%ARTI),no artist) - %IFV2(%TITL,%ICAP(%TITL) -,no title -) %IFV1(%ALBM,%IUPC(%ALBM))%IFV1(%YEAR, %(%YEAR%))"
         Output: "3.- Nightwish - Nemo - ONCE (2004)"

         if 'Artist' and 'Title' are empty, the output will be:
         "3. - no artist - no title - ONCE (2004)"

         if only 'Track' is empty, the output will be
         "Nightwish - Nemo - ONCE (2004)"

       Caution:
         "%IFV2(sometext ,a,b)" always evaluates to a, because a space after
         "sometext" causes the condition string to be not empty. This is
         intentional.

       Another caution:
         "symbols '%(,)' are reserved, that is, they must be escaped if they are
         inteded to appear in the output. See the above example: the parens
         around %YEAR are escaped with '%' to prevent misinterpretation.
#ce
$tags = _Bass_Tags_Read ($MusicHandle, "%IFV1(%TRCK,%TRCK. )%IFV2(%ARTI,%ICAP(%ARTI),no artist) - %IFV2(%TITL,%ICAP(%TITL) -,no title -) %IFV1(%ALBM,%IUPC(%ALBM))%IFV1(%YEAR, %(%YEAR%))")
MsgBox (0, "", $tags)

_Bass_Free()
