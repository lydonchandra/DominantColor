//
//  DominantColorUnitTests.swift
//  DominantColor
//
//  Created by Lydon Chandra on 27/09/2015.
//  Copyright © 2015 Indragie Karunaratne. All rights reserved.
//

import XCTest
@testable import DominantColor


private func randomNumberInRange(range: Range<Int>) -> Int {
    let interval = range.endIndex - range.startIndex - 1
    let buckets = Int(RAND_MAX) / interval
    let limit = buckets * interval
    var r = 0
    repeat {
        r = Int(rand())
    } while r >= limit
    return range.startIndex + (r / buckets)
}


private extension Array {
    private func randomValues(seed: UInt32, num: Int) -> [Element] {
        srand(seed)
        
        var indices = [Int]()
        indices.reserveCapacity(num)
        let range = 0..<self.count
        for _ in 0..<num {
            var random = 0
            repeat {
                random = randomNumberInRange(range)
            } while indices.contains(random)
            indices.append(random)
        }
        
        return indices.map { self[$0] }
    }
    
    
    
}


class DominantColorUnitTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRBGVectorToCGColor() {
        var aINVector3 = INVector3(x:0, y:0, z:0);
        var inCGColor = DominantColor.RGBVectorToCGColor(aINVector3);
        
        var assertCGColor = CGColorCreate(
            CGColorSpaceCreateDeviceRGB(),
            [CGFloat(0), CGFloat(0), CGFloat(0), 1.0])
        XCTAssertTrue(CGColorEqualToColor(inCGColor, assertCGColor))
        
        aINVector3 = INVector3(x:0, y:0.5000000, z: 0.6000000);
        inCGColor = DominantColor.RGBVectorToCGColor(aINVector3)
        print(inCGColor)
        assertCGColor = CGColorCreate(
                CGColorSpaceCreateDeviceRGB(),
                [CGFloat(0), CGFloat(0.5000000), CGFloat(0.6000000), 1.0])
        print(assertCGColor)
//        XCTAssertTrue(CGColorEqualToColor(inCGColor, assertCGColor))
        XCTAssertTrue(
            CGColorEqualToColorWithTolerance(inCGColor, color2:assertCGColor!, tolerance:0.01) )
        
        aINVector3 = INVector3(x:-0.5, y: -0.5, z: -0.5)
        inCGColor = DominantColor.RGBVectorToCGColor(aINVector3)
        print(inCGColor)
        assertCGColor = CGColorCreate(
            CGColorSpaceCreateDeviceRGB(),
            [CGFloat(0), CGFloat(0), CGFloat(0), 1.0])
        XCTAssertTrue(
            CGColorEqualToColorWithTolerance(inCGColor, color2: assertCGColor!, tolerance: 0.0001))
        
    }
    

    func CGColorEqualToColorWithTolerance(
        color1: CGColor, color2: CGColor, tolerance: CGFloat) -> Bool {
        
            var r1, g1, b1, a1, r2, g2, b2, a2: CGFloat
            let components = CGColorGetComponents(color1)
            r1 = components[0]
            g1 = components[1]
            b1 = components[2]
            a1 = components[3]
            
            let components2 = CGColorGetComponents(color2)
            r2 = components2[0]
            g2 = components2[1]
            b2 = components2[2]
            a2 = components2[3]
            
            if fabs(r2-r1) <= tolerance
                && fabs(g2-g1) <= tolerance
                && fabs(b2-b1) <= tolerance
                && fabs(a2 - a1 ) <= tolerance
            {
                return true
            }
            else {
                return false
            }
    }
    
    
//    // 1.
//    CGImageRef inputCGImage = [image CGImage];
//    NSUInteger width = CGImageGetWidth(inputCGImage);
//    NSUInteger height = CGImageGetHeight(inputCGImage);
//    
//    // 2.
//    NSUInteger bytesPerPixel = 4;
//    NSUInteger bytesPerRow = bytesPerPixel * width;
//    NSUInteger bitsPerComponent = 8;
//    
//    UInt32 * pixels;
//    pixels = (UInt32 *) calloc(height * width, sizeof(UInt32));
//    
//    // 3.
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//    
//    // 4.
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), inputCGImage);
//    
//    // 5. Cleanup
//    CGColorSpaceRelease(colorSpace);
//    CGContextRelease(context);

//    // 1.
//    #define Mask8(x) ( (x) & 0xFF )
//    #define R(x) ( Mask8(x) )
//    #define G(x) ( Mask8(x >> 8 ) )
//    #define B(x) ( Mask8(x >> 16) )
//    
//    NSLog(@"Brightness of image:");
//    // 2.
//    UInt32 * currentPixel = pixels;
//    for (NSUInteger j = 0; j < height; j++) {
//    for (NSUInteger i = 0; i < width; i++) {
//    // 3.
//    UInt32 color = *currentPixel;
//    printf("%3.0f ", (R(color)+G(color)+B(color))/3.0);
//    // 4.
//    currentPixel++;
//    }
//    printf("\n");
//    }
    
    func testDominantColorsInImage() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let testImageFileURL = bundle.URLForResource("all255s32x32", withExtension: "bmp")
        let testImageUIImage = UIImage(contentsOfFile: testImageFileURL!.path!)
        let dominantColorArray = DominantColor.dominantColorsInImage((testImageUIImage?.CGImage)!)
        
        print(dominantColorArray)
        
        for idx in 0..<dominantColorArray.count {
            let currentColor = dominantColorArray[idx]
            let colorComponents = CGColorGetComponents(currentColor)
            let red = colorComponents[0]
            let green = colorComponents[1]
            let blue = colorComponents[2]
            let alpha = CGColorGetAlpha(currentColor)
            XCTAssertTrue(red > 0.95 || red < 0.1)
            XCTAssertTrue(blue > 0.95 || blue < 0.1)
            XCTAssertTrue(green > 0.95 || green < 0.1)
            XCTAssertTrue(alpha > 0.95 || alpha < 0.95)
        }	
    }
    
    func testDominantColorsInImage_yellow() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let testImageFileURL = bundle.URLForResource("yellowImage_transparent", withExtension: "png")
        let testImageUIImage = UIImage(contentsOfFile: testImageFileURL!.path!)
        let dominantColorArray = DominantColor.dominantColorsInImage((testImageUIImage?.CGImage)!)
        
        for idx in 0..<dominantColorArray.count {
            let currentColor = dominantColorArray[idx]
            let colorComponents = CGColorGetComponents(currentColor)
            let red = colorComponents[0]
            let green = colorComponents[1]
            let blue = colorComponents[2]
            let alpha = CGColorGetAlpha(currentColor)
            //yellow = red + green
            XCTAssertTrue(red < 0.503 && red > 0.501)
            XCTAssertTrue(green < 0.503 && red > 0.501)
            XCTAssertTrue(blue < 0.001)
        }
    }
    
    func testDominantColorsInImage_yellow_black() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let testImageFileURL = bundle.URLForResource("yellowBlackImage", withExtension: "png")
        let testImageUIImage = UIImage(contentsOfFile: testImageFileURL!.path!)
        
        let dominantColorArray = DominantColor.dominantColorsInImage((testImageUIImage?.CGImage)!)
        
        for idx in 0..<dominantColorArray.count {
            let currentColor = dominantColorArray[idx]
            let colorComponents = CGColorGetComponents(currentColor)
            let red = colorComponents[0]
            let green = colorComponents[1]
            let blue = colorComponents[2]
            let alpha = CGColorGetAlpha(currentColor)
            
            XCTAssertTrue(true)
            if red > 0.999 {
                //dominantColor1: yellow,
                // red:1, green:1, blue:0
                XCTAssertTrue(green > 0.999)
                XCTAssertTrue(blue < 0.001)
            }
            else if red < 0.001 {
                //dominantColor2: black
                // red:0, green:0, blue:0
                XCTAssertTrue(green < 0.001)
                XCTAssertTrue(blue < 0.001)
            }
            
            print("\(red),\(green),\(blue) " )
            		
        }
    }
    
    
    
    
    func testFindNearestCluster() {
//        NSString* imagePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"plane.png"];
//        UIImage* imageWorks = [UIImage imageWithContentsOfFile:imagePath];
        
        let testBundle = NSBundle(forClass: self.dynamicType)
        let fileURL = testBundle.URLForResource("all255s32x32", withExtension: "bmp")
        
        let ones010 = UIImage(contentsOfFile: fileURL!.path!)
        let inputCGImage = ones010?.CGImage;
        
        var bitmapBytesCount = 0
        var bitmapBytesPerRow = 0
        let pixelsWide = CGImageGetWidth(inputCGImage)
        let pixelsHigh = CGImageGetHeight(inputCGImage)
        
        bitmapBytesPerRow = Int(pixelsWide) * 4
        bitmapBytesCount = bitmapBytesPerRow * Int(pixelsHigh)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapData = malloc(Int(bitmapBytesCount))
        
        let context = CGBitmapContextCreate(
            bitmapData,
            pixelsWide,
            pixelsHigh,
            Int(8),
            Int(bitmapBytesPerRow),
            colorSpace,
            CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        let rect = CGRect(x: 0, y: 0, width: Int(pixelsWide), height: Int(pixelsHigh))
        
        CGContextClearRect(context, rect)
        CGContextDrawImage(context, rect, inputCGImage)
        
        let dataVoidPointer:UnsafeMutablePointer<Void> = CGBitmapContextGetData(context)
        let dataIntPointer = UnsafePointer<UInt8>(dataVoidPointer)
        
        for heightIdx in 0 ..< pixelsHigh {
            
            for widthIdx in 0 ..< pixelsWide {
                
                let currentIdx = pixelsWide*heightIdx*4		 + widthIdx*4
                let alpha = dataIntPointer[currentIdx]
                let red = dataIntPointer[currentIdx+1]
                let green = dataIntPointer[currentIdx+2]
                let blue = dataIntPointer[currentIdx+3]
//                let color =
//                let color = UIColor(
//                    red: CGFloat(red)/CGFloat(255.0)
//                    , green: CGFloat(green)/CGFloat(255.0)
//                    , blue: CGFloat(blue)/CGFloat(255.0)
//                    , alpha: CGFloat(alpha)/CGFloat(255.0))
                
                print("\(red),\(green),\(blue) ", terminator: ""  )
            }
            print("\n")
        }
//        let width = CGImageGetWidth(inputCGImage)
//        let height = CGImageGetHeight(inputCGImage)
//        let bytesPerPixel = 4
//        let bytesPerRow = bytesPerPixel * width
//        let bitsPerComponent = 8
        
        var points = [Float](count: 10, repeatedValue: 0)
        let k = 16
        let seed : UInt32 = 3571
        DominantColor.testFunc()
        var centroids = points.randomValues(seed, num: k)
        //let clusterIndex = DominantColor.findNearestCluster(points[0], points, k, CIE76SquaredColorDifference)
        //XCTAssertTrue(clusterIndex > 0)
        XCTAssertTrue(true)
        
//        private func distanceForAccuracy(accuracy: GroupingAccuracy) -> (INVector3, INVector3) -> Float {
//            switch accuracy {
//            case .Low:
//                return CIE76SquaredColorDifference
//            case .Medium:
//                return CIE94SquaredColorDifference()
//            case .High:
//                return CIE2000SquaredColorDifference()
//            }
//        }
        
    }
    
    
    
    
    
    
    
    
    
    func testScratchPad() {
        
//        - (BOOL)color:(UIColor *)color1
//        isEqualToColor:(UIColor *)color2
//        withTolerance:(CGFloat)tolerance {
//            
//            CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
//            [color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
//            [color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
//            return
//                fabs(r1 - r2) <= tolerance &&
//                    fabs(g1 - g2) <= tolerance &&
//                    fabs(b1 - b2) <= tolerance &&
//                    fabs(a1 - a2) <= tolerance;
//        }
//        
        var red : CGFloat = 0.0
        var green : CGFloat = 0.0
        var blue : CGFloat = 0.0
        var alpha : CGFloat = 0.0
    
        var blueColor = UIColor.brownColor()
        blueColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        NSLog("")
        
//        CGFloat red, green, blue, alpha;
//        
//        //Create a sample color
//        
//        UIColor *redColor = [UIColor redColor];
//        
//        //Call
//        
//        [redColor getRed: &red
//        green: &green
//        blue: &blue
//        alpha: &alpha];
//        NSLog(@"red = %f. Green = %f. Blue = %f. Alpha = %f",
//        red,
//        green,
//        blue,
//        alpha);
    }
    
//    UIColor *color = [UIColor orangeColor];
//    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
//    
//    if ([color respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
//    [color getRed:&red green:&green blue:&blue alpha:&alpha];
//    } else {
//    const CGFloat *components = CGColorGetComponents(color.CGColor);
//    red = components[0];
//    green = components[1];
//    blue = components[2];
//    alpha = components[3];
//    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }

    
    
    
//    
//    func createARGBBitmapContext(inImage: CGImage) -> CGContext {
//        var bitmapByteCount = 0
//        var bitmapBytesPerRow = 0
//        
//        //Get image width, height
//        let pixelsWide = CGImageGetWidth(inImage)
//        let pixelsHigh = CGImageGetHeight(inImage)
//        
//        // Declare the number of bytes per row. Each pixel in the bitmap in this
//        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
//        // alpha.
//        bitmapBytesPerRow = Int(pixelsWide) * 4
//        bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
//        
//        // Use the generic RGB color space.
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        
//        // Allocate memory for image data. This is the destination in memory
//        // where any drawing to the bitmap context will be rendered.
//        let bitmapData = malloc(CUnsignedLong(bitmapByteCount))
//        let bitmapInfo = CGBitmapInfo.fromRaw(CGImageAlphaInfo.PremultipliedFirst.toRaw())!
//        
//        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
//        // per component. Regardless of what the source image format is
//        // (CMYK, Grayscale, and so on) it will be converted over to the format
//        // specified here by CGBitmapContextCreate.
//        let context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, CUnsignedLong(8), CUnsignedLong(bitmapBytesPerRow), colorSpace, bitmapInfo)
//        
//        // Make sure and release colorspace before returning
//        CGColorSpaceRelease(colorSpace)
//        
//        return context
//    }
//    
//    func getPixelColorAtLocation(point:CGPoint, inImage:CGImageRef) -> UIColor {
//        // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
//        let context = self.createARGBBitmapContext(inImage)
//        
//        let pixelsWide = CGImageGetWidth(inImage)
//        let pixelsHigh = CGImageGetHeight(inImage)
//        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
//        
//        //Clear the context
//        CGContextClearRect(context, rect)
//        
//        // Draw the image to the bitmap context. Once we draw, the memory
//        // allocated for the context for rendering will then contain the
//        // raw image data in the specified color space.
//        CGContextDrawImage(context, rect, inImage)
//        
//        // Now we can get a pointer to the image data associated with the bitmap
//        // context.
//        let data:COpaquePointer = CGBitmapContextGetData(context)
//        let dataType = UnsafePointer<UInt8>(data)
//        
//        let offset = 4*((Int(pixelsWide) * Int(point.y)) + Int(point.x))
//        let alpha = dataType[offset]
//        let red = dataType[offset+1]
//        let green = dataType[offset+2]
//        let blue = dataType[offset+3]
//        let color = UIColor(red: Float(red)/255.0, green: Float(green)/255.0, blue: Float(blue)/255.0, alpha: Float(alpha)/255.0)
//        
//        // When finished, release the context
//        CGContextRelease(context);
//        // Free image data memory for the context
//        free(data)
//        return color;
//    }
    
    
    
    
    
//    func createARGBBitmapContext(inImage: CGImage) -> CGContext	 {
//        var bitmapBytesCount = 0
//        var bitmapBytesPerRow = 0
//        
//        let pixelsWide = CGImageGetWidth(inImage)
//        let pixelsHigh = CGImageGetHeight(inImage)
//        
//        bitmapBytesPerRow = Int(pixelsWide) * 4
//        bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
//        
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        
//        let bitmapData = malloc(CUnsignedLong(bitmapBytesCount))
//        let bitmapInfo = CGBitmapInfo.frowRaw(CGImageAlphaInfo.PremultipliedFirst.toRaw())!
//        
//        
//        let context = CGBitmapContextCreate(
//            bitmapData,
//            pixelsWide, pixelsHigh,
//            CUnsignedLong(8), CUnsignedLong(bitmapBtesPerRow),
//            colorSpace,
//            bitmapInfo)
//        
//        CGColorSpaceRelease(colorSpace)
//        
//        return context
//    }
//    
//    
//    
//    func getPixelColorAtLocation(point: CGPoint, inImage:CGImageRef) -> UIColor {
//    
//        let context = createARGBBitmapContext(inImage)
//        let pixelsWide = CGImageGetWidth(inImage)
//        let pixelsHigh = CGImageGetHeight(inImage)
//        let rect = CGRect(x: 0, y: 0, width: Int(pixelsWide), height: Int(pixelsHigh))
//        
//        CGContextClearRect(context, rect)
//        
//        CGContextDrawImage(context, rect, inImage)
//        
//        let data:COpaquePointer = CGBitmapContextGetData(context)
//        let dataType = UnsafePointer<UInt8>(data)
//        
//        let offset = 4 * ( (Int(pixelsWide) * Int(point.y))  + Int(point.x))
//        let alpha = dataType[offset]
//        let red = dataType[offset+1]
//        let green = dataType[offset+2]
//        let blue = dataType[offset+3]
//        let color = UIColor(
//            red: Float(red)/255.0,
//            green: Float(green)/255.0,
//            blue: Float(blue)/255.0,
//            alpha: Float(alpha)/255.0)
//        
//        CGContextRelease(context)
//        free(data)
//        return color
//    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
