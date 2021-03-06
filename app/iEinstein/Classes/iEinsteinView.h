#import <UIKit/UIKit.h>
#include <K/Defines/KDefinitions.h>
#import "ChoosePackageView.h"
#import <GLKit/GLKit.h>

class TScreenManager;
class TEmulator;

@interface iEinsteinView : UIView

@property (nonatomic) TScreenManager *mScreenManager;
@property (nonatomic) TEmulator *mEmulator;
@property (nonatomic) CGImageRef mScreenImage;
@property (nonatomic) CGRect screenImageRect;
@property (nonatomic) KUInt32 newtonScreenHeight;
@property (nonatomic) KUInt32 newtonScreenWidth;

@property (strong, nonatomic) ChoosePackageView *choosePackageView;

- (void)reset;
- (void)setScreenManager:(TScreenManager *)sm;
- (void)setNeedsDisplayInNewtonRect:(NSValue *)v;

- (void)setEmulator:(TEmulator *)em;

@end
