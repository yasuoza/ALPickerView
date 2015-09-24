//
//  ALPickerView.m
//
//  Created by Alex Leutgöb on 11.11.11.
//  Copyright 2011 alexleutgoeb.com. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ALPickerView.h"
#import "ALPickerViewCell.h"

@interface ALPickerView()

@property (nonatomic) UIView *topOverlayView;
@property (nonatomic) UIView *topOverlayViewBottomBorder;

@property (nonatomic) UIView *bottomOverlayView;
@property (nonatomic) UIView *bottomOverlayViewTopBorder;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation ALPickerView

@synthesize allOptionTitle;


#pragma mark - NSObject stuff
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//- (id)init {
//    return [self initWithFrame:CGRectMake(0, 0, 320, 216)];
//}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self constructView];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
    // Set fix width and height
    if ((self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)])) {
        [self constructView];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)constructView {
    CGRect frame = self.frame;

    self.backgroundColor = [UIColor blackColor];
    self.clipsToBounds = YES;
    self.allOptionTitle = NSLocalizedString(@"All", @"All option title");

    internalTableView_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    internalTableView_.delegate = self;
    internalTableView_.dataSource = self;
    internalTableView_.separatorStyle = UITableViewCellSeparatorStyleNone;
    internalTableView_.showsVerticalScrollIndicator = NO;
    internalTableView_.scrollsToTop = NO;

    [self addSubview:internalTableView_];

    CGFloat overlayHeight = (frame.size.height - kALPickerViewCellHeight) / 2;
    UIColor *overlayColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    CGFloat borderHeight = 0.4;
    UIColor *borderColor = [UIColor lightGrayColor];

    _topOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, overlayHeight)];
    _topOverlayView.backgroundColor = overlayColor;
    [_topOverlayView setUserInteractionEnabled:NO];
    _topOverlayViewBottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, overlayHeight - borderHeight,
                                                                           frame.size.width, borderHeight)];
    _topOverlayViewBottomBorder.backgroundColor = borderColor;
    [_topOverlayView addSubview:_topOverlayViewBottomBorder];
    [self addSubview:_topOverlayView];

    _bottomOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, overlayHeight + kALPickerViewCellHeight,
                                                                         frame.size.width, overlayHeight)];
    _bottomOverlayView.backgroundColor = overlayColor;
    [_bottomOverlayView setUserInteractionEnabled:NO];
    _bottomOverlayViewTopBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, borderHeight)];
    _bottomOverlayViewTopBorder.backgroundColor = borderColor;
    [_bottomOverlayView addSubview:_bottomOverlayViewTopBorder];
    [self addSubview:_bottomOverlayView];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect frame = self.frame;
    CGFloat overlayHeight = (frame.size.height - kALPickerViewCellHeight) / 2;
    CGFloat borderHeight = 0.4;

    internalTableView_.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);

    _topOverlayView.frame = CGRectMake(0, 0, frame.size.width, overlayHeight);
    _topOverlayViewBottomBorder.frame = CGRectMake(0, overlayHeight - borderHeight, frame.size.width, borderHeight);

    _bottomOverlayView.frame = CGRectMake(0, overlayHeight + kALPickerViewCellHeight, frame.size.width, overlayHeight);
    _bottomOverlayViewTopBorder.frame = CGRectMake(0, 0, frame.size.width, borderHeight);
}


#pragma mark - Custom methods

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadAllComponents {
    [internalTableView_ reloadData];
}


#pragma mark - UITableView

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Add 4 additional rows for whitespace on top and bottom
    if (allOptionTitle)
        return [_delegate numberOfRowsForPickerView:self] ? [_delegate numberOfRowsForPickerView:self] + 5 : 0;
    else
        return [_delegate numberOfRowsForPickerView:self] ? [_delegate numberOfRowsForPickerView:self] + 4 : 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kALPickerViewCellHeight;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ALPVCell";

    ALPickerViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ALPickerViewCell alloc] initWithReuseIdentifier:CellIdentifier];
    }

    if (indexPath.row < 2 || indexPath.row >= ([_delegate numberOfRowsForPickerView:self] + (allOptionTitle ? 3 : 2))) {
        // Whitespace cell
        cell.textLabel.text = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        if (allOptionTitle && indexPath.row == 2) {
            cell.textLabel.text = allOptionTitle;
            BOOL allSelected = YES;
            for (int i = 0; i < [self.delegate numberOfRowsForPickerView:self]; i++) {
                if ([_delegate pickerView:self selectionStateForRow:i] == NO) {
                    allSelected = NO;
                    break;
                }
            }
            cell.selectionState = allSelected;
        }
        else {
            int actualRow = (int)indexPath.row - (allOptionTitle ? 3 : 2);
            cell.textLabel.text = [_delegate pickerView:self textForRow:actualRow];
            cell.selectionState = [_delegate pickerView:self selectionStateForRow:actualRow];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

    if (_cellFont) {
        cell.textLabel.font = _cellFont;
    }

    return cell;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 1 && indexPath.row < ([_delegate numberOfRowsForPickerView:self] + (allOptionTitle ? 3 : 2))) {
        // Set selection state
        ALPickerViewCell *cell = (ALPickerViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.selectionState = !cell.selectionState;

        // Inform delegate
        int actualRow = (int)indexPath.row - (allOptionTitle ? 3 : 2);

        if (cell.selectionState != NO) {
            if ([self.delegate respondsToSelector:@selector(pickerView:didCheckRow:)])
                [_delegate pickerView:self didCheckRow:actualRow];
        }
        else {
            if ([self.delegate respondsToSelector:@selector(pickerView:didUncheckRow:)])
                [_delegate pickerView:self didUncheckRow:actualRow];
        }

        // Iterate visible cells and update them too
        for (ALPickerViewCell *aCell in tableView.visibleCells) {
            int iterateRow = (int)[tableView indexPathForCell:aCell].row - (allOptionTitle ? 3 : 2);

            if (allOptionTitle && iterateRow == -1) {
                BOOL allSelected = YES;
                for (int i = 0; i < [self.delegate numberOfRowsForPickerView:self]; i++) {
                    if ([_delegate pickerView:self selectionStateForRow:i] == NO) {
                        allSelected = NO;
                        break;
                    }
                }
                aCell.selectionState = allSelected;
            }
            else if (iterateRow >= 0 && iterateRow < [_delegate numberOfRowsForPickerView:self]) {
                if (iterateRow == actualRow)
                    continue;
                aCell.selectionState = [_delegate pickerView:self selectionStateForRow:iterateRow];
            }
        }

        // Scroll the cell cell to the middle of the tableview
        [tableView setContentOffset:CGPointMake(0, kALPickerViewCellHeight * (indexPath.row - 2)) animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - ScrollView

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating:(UITableView *)tableView {
    int co = ((int)tableView.contentOffset.y % (int)kALPickerViewCellHeight);
    if (co < kALPickerViewCellHeight / 2) {
        [tableView setContentOffset:CGPointMake(0, tableView.contentOffset.y - co) animated:YES];
    } else {
        [tableView setContentOffset:CGPointMake(0, tableView.contentOffset.y + (kALPickerViewCellHeight - co)) animated:YES];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UITableView *)scrollView willDecelerate:(BOOL)decelerate {
    if(decelerate) {
        return;
    }
    [self scrollViewDidEndDecelerating:scrollView];
}

@end
