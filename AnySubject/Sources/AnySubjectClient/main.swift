import AnySubject
import Combine

final class Test {
    @AnySubject
    private let passThru = PassthroughSubject<Void, Error>()

    @AnySubject
    private let currentValue = CurrentValueSubject<Int, Error>(1)

//    @AnySubject
//    private let currentValue2 = 5

}
let test = Test()
print(test.passThruSubject)
print(test.currentValueSubject)
