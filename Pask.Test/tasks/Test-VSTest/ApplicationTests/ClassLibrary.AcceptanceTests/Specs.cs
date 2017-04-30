﻿using System;
using Machine.Fakes;
using Machine.Specifications;

namespace ClassLibrary.AcceptanceTests
{
    [Tags("category1")]
    [Subject(typeof(String))]
    public class StringSpec : WithSubject<String>
    {
        It should_be_true = () => true.ShouldBeTrue();

        Because of = () => { };

        Establish context = () => { };
    }
}
