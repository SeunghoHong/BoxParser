
import UIKit

/*
 abstract aligned(8) expandable(228-1) class BaseDescriptor : bit(8) tag=0 { 
    // empty. To be filled by classes extending this class.
 }

 */
/*
 class ES_Descriptor extends BaseDescriptor : bit(8) tag=ES_DescrTag {
 bit(16) ES_ID;
 bit(1) streamDependenceFlag;
 bit(1) URL_Flag;
 bit(1) OCRstreamFlag;
 bit(5) streamPriority;
 if (streamDependenceFlag) {
    bit(16) dependsOn_ES_ID;
 }
 if (URL_Flag) {
    bit(8) URLlength;
    bit(8) URLstring[URLlength];
 }
 if (OCRstreamFlag) {
    bit(16) OCR_ES_Id;
 }
 DecoderConfigDescriptor decConfigDescr;
 if (ODProfileLevelIndication==0x01) {      //no SL extension.
    SLConfigDescriptor slConfigDescr;
 } else {                                   // SL extension is possible.
    SLConfigDescriptor slConfigDescr;
 }
 IPI_DescrPointer ipiPtr[0 .. 1];
 IP_IdentificationDataSet ipIDS[0 .. 255];
 IPMP_DescriptorPointer ipmpDescrPtr[0 .. 255];
 LanguageDescriptor langDescr[0 .. 255];
 QoS_Descriptor qosDescr[0 .. 1];
 RegistrationDescriptor regDescr[0 .. 1];
 ExtensionDescriptor extDescr[0 .. 255];
 }
 */

// ISO 14496-1 7.2.6
protocol BaseDescriptor {
    
}

struct ES_Descriptor: BaseDescriptor {
    
}