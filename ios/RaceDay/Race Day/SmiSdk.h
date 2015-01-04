
#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SmiResultStatus) {
    SD_WIFI = 1,
    SD_AVAILABLE = 2,
    SD_NOT_AVAILABLE = 3,
    SD_EXPIRY = 4
};

@interface SmiResult : NSObject
{
}

@property (assign, nonatomic) int       state;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* errMsg;

@end

@interface SmiSdk : NSObject
{
}

+(BOOL)isDataMiUrl:(NSString*)url;

+(SmiResult*)getSDAuth:(NSString*)url userId:(NSString*)userId appId:(NSString*)appId;

@end
