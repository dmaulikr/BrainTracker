#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@interface CPTTestAppPieChartController : UIViewController<CPTPieChartDataSource>
{
    @private
    CPTXYGraph *pieChart;
    NSMutableArray *dataForChart;
}

@property (readwrite, strong, nonatomic) NSMutableArray *dataForChart;

@end
