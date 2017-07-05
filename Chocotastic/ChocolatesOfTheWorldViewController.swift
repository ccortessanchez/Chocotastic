/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import RxCocoa

class ChocolatesOfTheWorldViewController: UIViewController {
  
  @IBOutlet private var cartButton: UIBarButtonItem!
  @IBOutlet private var tableView: UITableView!
  let europeanChocolates = Observable.just(Chocolate.ofEurope)
  let disposeBag = DisposeBag()
  
  //MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Chocolate!!!"
    setupCartObserver()
    setupCellConfiguration()
    setupCellTapHandling()
  }
  
  //MARK: Rx Setup
  
  private func setupCartObserver() {
    // Grab chocolates variable as observable
    // We call subscribe(onNext:) in order to find out about changes to the Observable's values subscribe(onNext:) accepts a closure that will be executed every time a value changes
    // Incoming parameter to the closure is the new value of Observable, we'll keep getting notifications until unsubscribing or subscription is disposed
    // We get back an Observer conforming Disposable
    // Add Observer to disposeBag to ensure subscription is disposed of when unsubscribing object is deallocated
    ShoppingCart.sharedCart.chocolates.asObservable()
      .subscribe(onNext: { chocolates in
      self.cartButton.title = "\(chocolates.count) \u{1f36b}"
    })
    .addDisposableTo(disposeBag)
  }
  
  private func setupCellConfiguration() {
    // We call bindTo() to associate europeanChocolates observable with the code that should get executed for each row in tableView
    // Calling rx we are able to access RxCocoa extensions for the class you call it on
    // We call Rx method items(). This allows Rx framework to call the dequeueing methods that would be called if the table had its original delegates
    // We pass in a block to be executed for each new item. We get back information about the row, chocolate at that row and cell
    // Take the disposable returned by bindTo() and add it to disposeBag
    europeanChocolates.bindTo(tableView
      .rx
      .items(cellIdentifier: ChocolateCell.Identifier, cellType: ChocolateCell.self)) {
        row, chocolate, cell in
      cell.configureWithChocolate(chocolate: chocolate)
    }
      .addDisposableTo(disposeBag)
  }
  
  private func setupCellTapHandling() {
    // Call tableView reactive extension modelSelected(), passing the Chocolate model to get the proper type of item back. Returns an Observable
    // Call subscribe(onNext:), passing a closure of what should be done very time a model is selected
    // Add selected chocolate to the cart
    // Make sure tapped row is deselected
    // subscribe(onNext:) returns a Disposable. Add the disposable to disposeBag
    tableView
      .rx
      .modelSelected(Chocolate.self)
      .subscribe(onNext: {
        chocolate in
        ShoppingCart.sharedCart.chocolates.value.append(chocolate)
        
        if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
          self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
      })
      .addDisposableTo(disposeBag)
  }
}

// MARK: - SegueHandler
extension ChocolatesOfTheWorldViewController: SegueHandler {
  
  enum SegueIdentifier: String {
    case
    GoToCart
  }
}
