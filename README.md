# MultipleService
This is an example how to collect data from multiple services. It is implemented using TDD, Adapter design pattern.

`MainService` is a protocol to abstract implementation detail. So the UI Layer doesn't know how the data come from.
`MainServiceAdapter` is a implementation of `MainService` that interact with other services to load, synchronise, combine and deliver data. The implementation is covered by Unit test.

## Diagram
<img width="842" alt="Screenshot 2021-12-19 at 3 57 52 PM" src="https://user-images.githubusercontent.com/1131493/146668035-72fc0794-15d1-42b1-b86f-f0a2154b3cad.png">
